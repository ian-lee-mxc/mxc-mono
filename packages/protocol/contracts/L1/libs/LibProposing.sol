// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

import {LibTxDecoder} from "../../libs/LibTxDecoder.sol";
import {IMintableERC20} from "../../common/IMintableERC20.sol";
import {LibUtils} from "./LibUtils.sol";
import {MXCData} from "../MXCData.sol";
import {AddressResolver} from "../../common/AddressResolver.sol";

library LibProposing {
    using LibTxDecoder for bytes;
    using SafeCastUpgradeable for uint256;
    using LibUtils for MXCData.BlockMetadata;
    using LibUtils for MXCData.State;

    event BlockCommitted(uint64 commitSlot, bytes32 commitHash);
    event BlockProposed(uint256 indexed id, MXCData.BlockMetadata meta);

    error L1_COMMITTED();
    error L1_EXTRA_DATA();
    error L1_GAS_LIMIT();
    error L1_ID();
    error L1_INPUT_SIZE();
    error L1_METADATA_FIELD();
    error L1_NOT_COMMITTED();
    error L1_SOLO_PROPOSER();
    error L1_TOO_MANY_BLOCKS();
    error L1_TX_LIST();
    error L1_FAST_PROPOSE();
    error L1_FAST_EMPTY_PROPOSE();

    function commitBlock(
        MXCData.State storage state,
        MXCData.Config memory config,
        uint64 commitSlot,
        bytes32 commitHash
    ) public {
        assert(config.commitConfirmations > 0);

        bytes32 hash = _aggregateCommitHash(
            LibUtils.getBlockNumber(),
            commitHash
        );

        if (state.commits[msg.sender][commitSlot] == hash)
            revert L1_COMMITTED();

        state.commits[msg.sender][commitSlot] = hash;

        emit BlockCommitted({commitSlot: commitSlot, commitHash: commitHash});
    }

    function proposeBlock(
        MXCData.State storage state,
        MXCData.Config memory config,
        AddressResolver resolver,
        bytes[] calldata inputs
    ) public {
        // For alpha-2 testnet, the network only allows an special address
        // to propose but anyone to prove. This is the first step of testing
        // the tokenomics.

        // TODO(daniel): remove this special address.
        // address soloProposer = resolver.resolve("solo_proposer", true);
        // if (soloProposer != address(0) && soloProposer != msg.sender)
        //    revert L1_SOLO_PROPOSER();

        if (inputs.length != 2) revert L1_INPUT_SIZE();
        MXCData.BlockMetadata memory meta = abi.decode(
            inputs[0],
            (MXCData.BlockMetadata)
        );
        _verifyBlockCommit({
            state: state,
            commitConfirmations: config.commitConfirmations,
            meta: meta
        });
        _validateMetadata(config, meta);

        IMintableERC20 mxcToken = IMintableERC20(
            resolver.resolve("mxc_token", false)
        );
        uint256 reward = _calcProposeReward(state, mxcToken.totalSupply());
        uint256 txListLength;
        {
            bytes calldata txList = inputs[1];
            // perform validation and populate some fields
            if (
                txList.length < 0 ||
                txList.length > config.maxBytesPerTxList ||
                meta.txListHash != txList.hashTxList()
            ) revert L1_TX_LIST();

            if (
                state.nextBlockId >=
                state.latestVerifiedId + config.maxNumBlocks
            ) revert L1_TOO_MANY_BLOCKS();
            txListLength = txList.length;
            // Change(MXC): block interval
            if (txList.length > 0) {
                if (
                    uint64(block.timestamp) - state.lastProposedAt <
                    config.blockInterval
                ) {
                    revert L1_FAST_PROPOSE();
                }
            }
            // Change(MXC): empty block interval
            if (txList.length == 0) {
                if (
                    uint64(block.timestamp) - state.lastProposedAt <
                    config.emptyBlockInterval
                ) {
                    revert L1_FAST_EMPTY_PROPOSE();
                }
            }

            meta.id = state.nextBlockId;
            meta.l1Height = LibUtils.getBlockNumber() - 1;
            meta.l1Hash = LibUtils.getBlockHash(LibUtils.getBlockNumber() - 1);
            meta.timestamp = uint64(block.timestamp);

//            meta.extraData = bytes.concat(bytes32(reward));
            // After The Merge, L1 mixHash contains the prevrandao
            // from the beacon chain. Since multiple MXC blocks
            // can be proposed in one Ethereum block, we need to
            // add salt to this random number as L2 mixHash
            meta.mixHash = keccak256(
                abi.encodePacked(block.prevrandao, state.nextBlockId)
            );
        }

        uint256 deposit;
        if (config.enableTokenomics) {
            uint256 newFeeBase;
            {
                uint256 fee;
                (newFeeBase, fee, deposit) = getBlockFee(state, config);
                mxcToken.burn(msg.sender, fee + deposit);
            }
            // Update feeBase and avgBlockTime
            state.feeBase = LibUtils.movingAverage({
                maValue: state.feeBase,
                newValue: newFeeBase,
                maf: config.feeBaseMAF
            });
        }
        if(txListLength > 0) {
            mxcToken.mint(msg.sender, reward);
        }else {
            // to miningPool
            mxcToken.mint(resolver.resolve("token_vault", false), reward);
        }
        state.rewards[state.nextBlockId] = reward;

        _saveProposedBlock(
            state,
            config.maxNumBlocks,
            state.nextBlockId,
            MXCData.ProposedBlock({
                metaHash: meta.hashMetadata(),
                deposit: deposit,
                proposer: msg.sender,
                proposedAt: meta.timestamp
            })
        );

        state.avgBlockTime = LibUtils
            .movingAverage({
                maValue: state.avgBlockTime,
                newValue: meta.timestamp - state.lastProposedAt,
                maf: config.blockTimeMAF
            })
            .toUint64();

        state.lastProposedAt = meta.timestamp;

        emit BlockProposed(state.nextBlockId++, meta);
    }

    function _calcProposeReward(
        MXCData.State storage state,
        uint256 totalSupply
    ) public view returns (uint256 reward) {
        reward =
            (totalSupply / 7 / 365 days) *
            (block.timestamp - state.lastProposedAt);
    }

    function getBlockFee(
        MXCData.State storage state,
        MXCData.Config memory config
    ) public view returns (uint256 newFeeBase, uint256 fee, uint256 deposit) {
        (newFeeBase, ) = LibUtils.getTimeAdjustedFee({
            state: state,
            config: config,
            isProposal: true,
            tNow: uint64(block.timestamp),
            tLast: state.lastProposedAt,
            tAvg: state.avgBlockTime,
            tCap: config.blockTimeCap
        });
        fee = LibUtils.getSlotsAdjustedFee({
            state: state,
            config: config,
            isProposal: true,
            feeBase: newFeeBase
        });
        fee = LibUtils.getBootstrapDiscountedFee(state, config, fee);
        deposit = (fee * config.proposerDepositPctg) / 100;
    }

    function isCommitValid(
        MXCData.State storage state,
        uint256 commitConfirmations,
        uint256 commitSlot,
        uint256 commitHeight,
        bytes32 commitHash
    ) public view returns (bool) {
        assert(commitConfirmations > 0);
        bytes32 hash = _aggregateCommitHash(commitHeight, commitHash);
        return
            state.commits[msg.sender][commitSlot] == hash &&
            LibUtils.getBlockNumber() >= commitHeight + commitConfirmations;
    }

    function getProposedBlock(
        MXCData.State storage state,
        uint256 maxNumBlocks,
        uint256 id
    ) internal view returns (MXCData.ProposedBlock storage) {
        if (id <= state.latestVerifiedId || id >= state.nextBlockId) {
            revert L1_ID();
        }
        return state.getProposedBlock(maxNumBlocks, id);
    }

    function _saveProposedBlock(
        MXCData.State storage state,
        uint256 maxNumBlocks,
        uint256 id,
        MXCData.ProposedBlock memory blk
    ) private {
        state.proposedBlocks[id % maxNumBlocks] = blk;
    }

    function _verifyBlockCommit(
        MXCData.State storage state,
        uint256 commitConfirmations,
        MXCData.BlockMetadata memory meta
    ) private view {
        if (commitConfirmations == 0) {
            return;
        }
        bytes32 commitHash = _calculateCommitHash(
            meta.beneficiary,
            meta.txListHash
        );

        if (
            !isCommitValid({
                state: state,
                commitConfirmations: commitConfirmations,
                commitSlot: meta.commitSlot,
                commitHeight: meta.commitHeight,
                commitHash: commitHash
            })
        ) revert L1_NOT_COMMITTED();
    }

    function _validateMetadata(
        MXCData.Config memory config,
        MXCData.BlockMetadata memory meta
    ) private pure {
        if (
            meta.id != 0 ||
            meta.l1Height != 0 ||
            meta.l1Hash != 0 ||
            meta.mixHash != 0 ||
            meta.timestamp != 0 ||
            meta.beneficiary == address(0) ||
            meta.txListHash == 0
        ) revert L1_METADATA_FIELD();

        if (meta.gasLimit > config.blockMaxGasLimit) revert L1_GAS_LIMIT();
        if (meta.extraData.length > 32) {
            revert L1_EXTRA_DATA();
        }
    }

    function _calculateCommitHash(
        address beneficiary,
        bytes32 txListHash
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(beneficiary, txListHash));
    }

    function _aggregateCommitHash(
        uint256 commitHeight,
        bytes32 commitHash
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(commitHash, commitHeight));
    }
}
