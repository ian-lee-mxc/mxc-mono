// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibMath} from "../../libs/LibMath.sol";
import {SafeCastUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MxcData} from "../MxcData.sol";
import {MxcToken} from "../MxcToken.sol";
import {LibFixedPointMath as Math} from "../../thirdparty/LibFixedPointMath.sol";

library LibTokenomics {
    using LibMath for uint256;

    error L1_INSUFFICIENT_TOKEN();

    error L1_DEPOSIT_REQUIREMENT();

    error L1_NOT_UNLOCK();

    function withdrawMxcToken(MxcData.State storage state, AddressResolver resolver, uint256 amount)
        internal
    {
        uint256 balance = state.mxcTokenBalances[msg.sender];
        if (balance < amount) revert L1_INSUFFICIENT_TOKEN();
        if (state.mxcTokenWithdrawalReleaseTime[msg.sender] == 0) revert L1_NOT_UNLOCK();
        if (state.mxcTokenWithdrawalReleaseTime[msg.sender] > block.timestamp) {
            revert L1_NOT_UNLOCK();
        }

        unchecked {
            state.mxcTokenBalances[msg.sender] -= amount;
        }

        state.mxcTokenWithdrawalReleaseTime[msg.sender] = 0;
        MxcToken(resolver.resolve("mxc_token", false)).mint(msg.sender, amount);
    }

    function unStakeMxcToken(MxcData.State storage state) internal {
        if (state.mxcTokenBalances[msg.sender] > 0) {
            state.mxcTokenWithdrawalReleaseTime[msg.sender] = block.timestamp + 28 days;
        }
    }

    function getUnlockTime(MxcData.State storage state) internal view returns (uint256) {
        return state.mxcTokenWithdrawalReleaseTime[msg.sender];
    }

    function depositMxcToken(MxcData.State storage state, AddressResolver resolver, uint256 amount)
        internal
    {
        if (amount > 0) {
            // 6m stake limit
            if (state.mxcTokenBalances[msg.sender] + amount < 6000000 * 1e18) {
                revert L1_DEPOSIT_REQUIREMENT();
            }
            MxcToken(resolver.resolve("mxc_token", false)).burn(msg.sender, amount);
            state.mxcTokenWithdrawalReleaseTime[msg.sender] = 0;
            state.mxcTokenBalances[msg.sender] += amount;
        }
    }

    /**
     * Get the block reward for a proof
     *
     * @param state The actual state data
     * @param proofTime The actual proof time
     * @return reward The reward given for the block proof
     */
    function getProofReward(MxcData.State storage state, uint64 proofTime)
        internal
        view
        returns (uint64)
    {
        uint64 numBlocksUnverified = state.numBlocks - state.lastVerifiedBlockId - 1;

        if (numBlocksUnverified == 0) {
            return 0;
        } else {
            uint64 totalNumProvingSeconds =
                uint64(uint256(numBlocksUnverified) * block.timestamp - state.accProposedAt);
            // If block timestamp is equal to state.accProposedAt (not really,
            // but theoretically possible) there will be division by 0 error
            if (totalNumProvingSeconds == 0) {
                totalNumProvingSeconds = 1;
            }

            return uint64((uint256(state.accBlockFees) * proofTime) / totalNumProvingSeconds);
        }
    }

    /**
     * Calculate the newProofTimeIssued and blockFee
     *
     * @param state The actual state data
     * @param proofTime The actual proof time
     * @return newProofTimeIssued Accumulated proof time
     * @return blockFee New block fee
     */
    function getNewBlockFeeAndProofTimeIssued(MxcData.State storage state, uint64 proofTime)
        internal
        view
        returns (uint64 newProofTimeIssued, uint64 blockFee)
    {
        newProofTimeIssued = (state.proofTimeIssued > state.proofTimeTarget)
            ? state.proofTimeIssued - state.proofTimeTarget
            : uint64(0);
        newProofTimeIssued += proofTime;

        uint256 x = (newProofTimeIssued * Math.SCALING_FACTOR_1E18)
            / (state.proofTimeTarget * state.adjustmentQuotient);

        if (Math.MAX_EXP_INPUT <= x) {
            x = Math.MAX_EXP_INPUT;
        }

        uint256 result = (uint256(Math.exp(int256(x))) / Math.SCALING_FACTOR_1E18)
            / (state.proofTimeTarget * state.adjustmentQuotient);

        blockFee = uint64(result.min(type(uint64).max));
    }
}
