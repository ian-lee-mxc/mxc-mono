// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {ISignalService} from "../../signal/ISignalService.sol";
import {EtherVault} from "../EtherVault.sol";
import {LibBridgeData} from "./LibBridgeData.sol";
import {LibBridgeInvoke} from "./LibBridgeInvoke.sol";
import {LibBridgeStatus} from "./LibBridgeStatus.sol";
import {LibMath} from "../../libs/LibMath.sol";
import {LibAddress} from "../../libs/LibAddress.sol";
import {IBridge} from "../IBridge.sol";
import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibSharedConfig} from "../../libs/LibSharedConfig.sol";
import {
    SafeERC20Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {ERC20Upgradeable} from "../../thirdparty/ERC20Upgradeable.sol";
import {TokenVault} from "../TokenVault.sol";

/**
 * Process bridge messages on the destination chain.
 * @title LibBridgeProcess
 */
library LibBridgeProcess {
    using SafeERC20Upgradeable for ERC20Upgradeable;
    using LibMath for uint256;
    using LibAddress for address;
    using LibBridgeData for IBridge.Message;
    using LibBridgeData for LibBridgeData.State;

    error B_FORBIDDEN();
    error B_STATUS_MISMTACH();
    error B_SIGNAL_NOT_RECEIVED();
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
        if (
            LibBridgeStatus.getMessageStatus(msgHash) !=
            LibBridgeStatus.MessageStatus.NEW
        ) {
            revert B_STATUS_MISMTACH();
        }
        // Message must have been "received" on the destChain (current chain)
        address srcBridge = resolver.resolve(
            message.srcChainId,
            "bridge",
            false
        );

        if (
            !ISignalService(resolver.resolve("signal_service", false))
                .isSignalReceived({
                    srcChainId: message.srcChainId,
                    app: srcBridge,
                    signal: msgHash,
                    proof: proof
                })
        ) {
            revert B_SIGNAL_NOT_RECEIVED();
        }

        LibBridgeStatus.MessageStatus status;
        uint256 refundAmount;
        TokenVault tokenVault = TokenVault(resolver.resolve("token_vault", false));
        // if the user is sending to the bridge or zero-address, just process as DONE
        // and refund the owner
        if (message.to == address(this) || message.to == address(0)) {
            // For these two special addresses, the call will not be actually
            // invoked but will be marked DONE. The callValue will be refunded.
            status = LibBridgeStatus.MessageStatus.DONE;
            refundAmount = message.callValue;
        } else if (message.srcChainId == LibSharedConfig.getConfig().chainId && message.depositValue > 0) {
            // change(MXC) release live chain mxc
            tokenVault.receiveMXC(
                message.owner,
                message.depositValue
            );
            status = LibBridgeStatus.MessageStatus.DONE;
        } else {
            // release eth(mxc) on mxc chain
            if (_checkAndReleaseEther(message, resolver)) {
                status = LibBridgeStatus.MessageStatus.DONE;
            } else {
                // use the specified message gas limit if not called by the owner
                uint256 gasLimit = msg.sender == message.owner
                    ? gasleft()
                    : message.gasLimit;

                // this will call receiveERC20 on the tokenVault, sending the tokens to the user
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
                }
            }
        }
        // Mark the status as DONE or RETRIABLE.
        LibBridgeStatus.updateMessageStatus(msgHash, status);

        address refundAddress = message.refundAddress == address(0)
        ? message.owner
        : message.refundAddress;

        // if sender is the refundAddress
        if (msg.sender == refundAddress) {
            uint256 amount = message.processingFee + refundAmount;
            if(message.srcChainId == LibSharedConfig.getConfig().chainId) {
                // change(MXC) release live chain mxc
                tokenVault.receiveMXC(
                    refundAddress,
                    amount
                );
            }else {
                // send mxc on mxc chain
                refundAddress.sendEther(amount);
            }
        } else {
            // if sender is another address (eg. the relayer)
            // First attempt relayer is rewarded the processingFee
            // message.owner has to eat the cost
            if(message.srcChainId == LibSharedConfig.getConfig().chainId) {
                // change(MXC) release live chain mxc
                tokenVault.receiveMXC(
                    msg.sender,
                    message.processingFee
                );
                tokenVault.receiveMXC(
                    refundAddress,
                    refundAmount
                );
            }else {
                // send mxc on mxc chain
                msg.sender.sendEther(message.processingFee);
                refundAddress.sendEther(refundAmount);
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
    function _checkAndReleaseEther(
        IBridge.Message calldata message,
        AddressResolver resolver
    ) internal returns (bool) {
        (CanonicalERC20 memory token, , address to, uint256 amount) = abi
            .decode(
                message.data[4:],
                (CanonicalERC20, address, address, uint256)
            );
        // change(MXC) release ether
        if (
            token.addr ==
            resolver.resolve(message.srcChainId, "mxc_token", false) &&
            message.destChainId == LibSharedConfig.getConfig().chainId
        ) {
            EtherVault(payable(resolver.resolve("ether_vault", false)))
                .releaseEther(to, amount);
            return true;
        }
        return false;
    }
}
