// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {EtherVault} from "../EtherVault.sol";
import {IBridge} from "../IBridge.sol";
import {ISignalService} from "../../signal/ISignalService.sol";
import {LibAddress} from "../../libs/LibAddress.sol";
import {LibBridgeData} from "./LibBridgeData.sol";
import {LibBridgeInvoke} from "./LibBridgeInvoke.sol";
import {LibBridgeStatus} from "./LibBridgeStatus.sol";
import {LibMath} from "../../libs/LibMath.sol";
import {TokenVault} from "../TokenVault.sol";
import {MxcConfig} from "../../L1/MxcConfig.sol";

/**
 * Process bridge messages on the destination chain.
 * @title LibBridgeProcess
 */
library LibBridgeProcess {
    using LibMath for uint256;
    using LibAddress for address;
    using LibBridgeData for IBridge.Message;
    using LibBridgeData for LibBridgeData.State;

    error B_FORBIDDEN();
    error B_SIGNAL_NOT_RECEIVED();
    error B_STATUS_MISMATCH();
    error B_WRONG_CHAIN_ID();

    /**
     * Process the bridge message on the destination chain. It can be called by
     * any address, including `message.owner`. It starts by hashing the message,
     * and doing a lookup in the bridge state to see if the status is "NEW". It
     * then takes custody of the ether from the EtherVault and attempts to
     * invoke the messageCall, changing the message's status accordingly.
     * Finally, it refunds the processing fee if needed.
     * @param state The bridge state.
     * @param resolver The address resolver.
     * @param message The message to process.
     * @param proof The msgHash proof from the source chain.
     */
    function processMessage(
        LibBridgeData.State storage state,
        AddressResolver resolver,
        IBridge.Message calldata message,
        bytes calldata proof
    ) internal {
        // If the gas limit is set to zero, only the owner can process the message.
        if (message.gasLimit == 0 && msg.sender != message.owner) {
            revert B_FORBIDDEN();
        }

        if (message.destChainId != block.chainid) {
            revert B_WRONG_CHAIN_ID();
        }

        // The message status must be "NEW"; "RETRIABLE" is handled in
        // LibBridgeRetry.sol.
        bytes32 msgHash = message.hashMessage();
        if (LibBridgeStatus.getMessageStatus(msgHash) != LibBridgeStatus.MessageStatus.NEW) {
            revert B_STATUS_MISMATCH();
        }
        // Message must have been "received" on the destChain (current chain)
        address srcBridge = resolver.resolve(message.srcChainId, "bridge", false);

        if (
            !ISignalService(resolver.resolve("signal_service", false)).isSignalReceived({
                srcChainId: message.srcChainId,
                app: srcBridge,
                signal: msgHash,
                proof: proof
            })
        ) {
            revert B_SIGNAL_NOT_RECEIVED();
        }

        bool isMxc = block.chainid == MxcConfig.getConfig().chainId;

        uint256 allValue = message.depositValue + message.callValue + message.processingFee;
        // We retrieve the necessary ether from EtherVault if receiving on
        // Mxc, otherwise it is already available in this Bridge.
        EtherVault etherVault = EtherVault(payable(resolver.resolve("ether_vault", true)));
        TokenVault tokenVault = TokenVault(payable(resolver.resolve("token_vault", false)));

        if ((allValue > 0) && isMxc) {
            etherVault.releaseEther(allValue);
        }

        // weth withdrawal and release callValue Ether
        if(!isMxc && message.callValue > 0) {
            tokenVault.releaseEther(message.callValue);
        }

        // We send the Ether before the message call in case the call will
        // actually consume Ether.
        if(isMxc) {
            message.owner.sendEther(message.depositValue);
        }else {
            if(message.depositValue > 0) {
                tokenVault.receiveMXC(message.owner, message.depositValue);
            }
        }

        LibBridgeStatus.MessageStatus status;
        uint256 refundAmount;
        // change(MXC) chain token mxc

        // if the user is sending to the bridge or zero-address, just process as DONE
        // and refund the owner
        if (message.to == address(this) || message.to == address(0)) {
            // For these two special addresses, the call will not be actually
            // invoked but will be marked DONE. The callValue will be refunded.
            status = LibBridgeStatus.MessageStatus.DONE;
            refundAmount = message.callValue;
        } else {
            // CHANGE(MXC): unpack message data and process it if mxc token
            if (_checkAndReleaseEther(message, resolver) && isMxc) {
                status = LibBridgeStatus.MessageStatus.DONE;
            } else {
                // use the specified message gas limit if not called by the owner
                uint256 gasLimit = msg.sender == message.owner ? gasleft() : message.gasLimit;

                bool success = LibBridgeInvoke.invokeMessageCall({
                    state: state,
                    message: message,
                    msgHash: msgHash,
                    gasLimit: gasLimit
                });
                if (success) {
                    status = LibBridgeStatus.MessageStatus.DONE;
                } else {
                    status = LibBridgeStatus.MessageStatus.RETRIABLE;
                    if(isMxc) {
                        address(etherVault).sendEther(message.callValue);
                    }else {
                        // unused ETH send to tokenVault
                        if(message.callValue > 0) {
                            tokenVault.depositToWETH{value: message.callValue}();
                        }
                    }
                }
            }
        }

        // Mark the status as DONE or RETRIABLE.
        LibBridgeStatus.updateMessageStatus(msgHash, status);

        address refundAddress =
            message.refundAddress == address(0) ? message.owner : message.refundAddress;

        // if sender is the refundAddress
        if (msg.sender == refundAddress) {
            uint256 amount = message.processingFee + refundAmount;
            if (isMxc) {
                // send mxc on mxc chain
                refundAddress.sendEther(message.processingFee);
                // refund callValue with weth
                if(refundAmount > 0) {
                    tokenVault.receiveWETH(message.owner, refundAmount);
                }
            }else {
                if(amount > 0) {
                    tokenVault.receiveMXC(message.owner, amount);
                }
            }
        } else {
            // if sender is another address (eg. the relayer)
            // First attempt relayer is rewarded the processingFee
            // message.owner has to eat the cost
            if (isMxc) {
                // send mxc on mxc chain
                msg.sender.sendEther(message.processingFee);
                if(refundAmount > 0) {
                    tokenVault.receiveWETH(refundAddress, refundAmount);
                }
            }else {
                if(message.processingFee > 0) {
                    tokenVault.receiveMXC(msg.sender, message.processingFee);
                }
                if(refundAmount > 0) {
                    tokenVault.receiveWETH(message.owner, refundAmount);
                }
            }
        }
    }

    struct CanonicalERC20 {
        uint256 chainId;
        address addr;
        uint8 decimals;
        string symbol;
        string name;
    }

    /**
     * Special case for releasing ether
     * @param message The message to process.
     * @param resolver The address resolver.
     */
    function _checkAndReleaseEther(IBridge.Message calldata message, AddressResolver resolver)
        internal
        returns (bool)
    {
        if (message.data.length == 0) {
            return false;
        }
        (CanonicalERC20 memory token,, address to, uint256 amount) =
            abi.decode(message.data[4:], (CanonicalERC20, address, address, uint256));
        // change(MXC) release ether
        if (token.addr == resolver.resolve(message.srcChainId, "mxc_token", true)) {
            EtherVault(payable(resolver.resolve("ether_vault", false))).releaseEther(to, amount);
            return true;
        }
        return false;
    }
}
