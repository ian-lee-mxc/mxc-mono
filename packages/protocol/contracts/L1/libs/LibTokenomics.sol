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
            state.totalStakeMxcTokenBalances -= amount;
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
            if(state.mxcTokenBalances[msg.sender] == 0) {
                if (amount < 6000000 * 1e18) {
                    revert L1_DEPOSIT_REQUIREMENT();
                }
            }
            MxcToken(resolver.resolve("mxc_token", false)).burn(msg.sender, amount);
            state.mxcTokenWithdrawalReleaseTime[msg.sender] = 0;
            state.mxcTokenBalances[msg.sender] += amount;
            state.totalStakeMxcTokenBalances += amount;
        }
    }

    /**
     * Get the block reward for a proof
     *
     * @param state The actual state data
     * @param proofTime The actual proof time
     * @return reward The reward given for the block proof
     */
    function getProofReward(AddressResolver resolver, MxcData.Config memory config, MxcData.State storage state, uint64 proofTime)
        internal
        view
        returns (uint256)
    {
        uint64 numBlocksUnverified = state.numBlocks - state.lastVerifiedBlockId - 1;
        uint64 avgBlockTime = (uint64(block.timestamp) - state.blocks[state.lastVerifiedBlockId % config.ringBufferSize].proposedAt) / numBlocksUnverified;

        if(avgBlockTime > state.proofTimeTarget * 2) {
            avgBlockTime = state.proofTimeTarget * 2;
        }

        if (numBlocksUnverified == 0 || state.lastVerifiedBlockId == 0) {
            return 0;
        } else {
            // CHANGE(MXC): proof reward
            uint256 baseReward = (MxcToken(resolver.resolve("mxc_token", false)).totalSupply() / 14 / 365 days) * avgBlockTime / 2;

            uint proofRate = 1;
            if (proofTime != 0) {
                uint256 proofRate = state.proofTimeTarget / proofTime;
                if(proofRate > 1) {
                    proofRate = 1;
                }
            }
            uint256 proofTimeAddtionReward = baseReward * proofRate;

            uint256 reward = (baseReward + proofTimeAddtionReward);
            if(reward > 1e22) {
                reward = 1e22;
            }

            return (reward / 1e16) * 1e16;
        }
    }

    /**
     * Get the block reward for the block propose
     *
     * @param state The actual state data
     * @return reward The reward given for the block propose
     */
    function getProposeReward(AddressResolver resolver, MxcData.Config memory config, MxcData.State storage state) internal view returns (uint256) {
        MxcData.Block storage blk = state.blocks[(state.numBlocks - 1) % config.ringBufferSize];
        uint256 elapsedSeconds = block.timestamp - blk.proposedAt;
        if(elapsedSeconds == 0) {
            elapsedSeconds = 1;
        }
        uint reward = (MxcToken(resolver.resolve("mxc_token", false)).totalSupply() / 20 / 365 days) * elapsedSeconds;
        if(reward > 1e22) {
            reward = 1e22;
        }
        return (reward / 1e16) * 1e16;
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

        // Keep it within 0.1 and 10 MXC and not allow proofTimeIssued accumulated
        // so that fee could recover quicker when waiting is applied from provers.
        if (blockFee < 1e7) {
            blockFee = 1e7;
            newProofTimeIssued -= proofTime;
        } else if (blockFee > 1e9) {
            blockFee = 1e9;
            newProofTimeIssued -= proofTime;
        }
    }

    function mintReward(AddressResolver resolver,uint256 amount) internal {
        if(amount != 0) {
            MxcToken(resolver.resolve("mxc_token", false)).mint(resolver.resolve("token_vault", false), amount);
        }
    }
}
