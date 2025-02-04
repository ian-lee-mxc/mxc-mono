// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibAddress} from "../../libs/LibAddress.sol";
import {LibEthDepositing} from "./LibEthDepositing.sol";
import {LibUtils} from "./LibUtils.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {SafeCastUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MxcData} from "../MxcData.sol";
import {AggregatorInterface} from "../../common/AggregatorInterface.sol";

interface IArbGasInfo {
    function getMinimumGasPrice() external view returns (uint256);
}

library LibProposing {
    using SafeCastUpgradeable for uint256;
    using LibAddress for address;
    using LibAddress for address payable;
    using LibUtils for MxcData.State;

    event BlockProposed(uint256 indexed id, MxcData.BlockMetadata meta, uint64 blockFee);
    event BlockProposeReward(uint256 indexed id, address proposer, uint256 reward);

    error L1_BLOCK_ID();
    error L1_INSUFFICIENT_TOKEN();
    error L1_INVALID_METADATA();
    error L1_TOO_MANY_BLOCKS();
    error L1_TX_LIST_NOT_EXIST();
    error L1_TX_LIST_HASH();
    error L1_TX_LIST_RANGE();
    error L1_TX_LIST();

    function proposeBlock(
        MxcData.State storage state,
        MxcData.Config memory config,
        AddressResolver resolver,
        MxcData.BlockMetadataInput memory input,
        bytes memory txList,
        uint128 txListLength,
        uint128 estimateGas
    ) internal returns (MxcData.BlockMetadata memory meta) {
        uint256 gasStart = gasleft();

        uint8 cacheTxListInfo =
            _validateBlock({state: state, config: config, input: input, txList: txList, txListLength: uint256(txListLength)});

        if (cacheTxListInfo != 0) {
            state.txListInfo[input.txListHash] = MxcData.TxListInfo({
                validSince: uint64(block.timestamp),
                size: uint24(txListLength)
            });
        }

        // After The Merge, L1 mixHash contains the prevrandao
        // from the beacon chain. Since multiple Taiko blocks
        // can be proposed in one Ethereum block, we need to
        // add salt to this random number as L2 mixHash

        meta.id = state.numBlocks;
        meta.txListHash = input.txListHash;
        meta.txListByteStart = input.txListByteStart;
        meta.txListByteEnd = input.txListByteEnd;
        meta.gasLimit = input.gasLimit;
        meta.beneficiary = input.beneficiary;
        meta.treasury = resolver.resolve(config.chainId, "treasury", false);
        //        meta.depositsProcessed = LibEthDepositing.processDeposits(state, config, input.beneficiary);

        uint256 proposeReward = LibTokenomics.getProposeReward(resolver, config, state);
        meta.blockReward = uint256(state.proveMetaReward) * 1e16 + proposeReward;
        state.proveMetaReward = 0;
        if (meta.blockReward > 0) {
            LibTokenomics.mintReward(resolver, meta.blockReward);
        }

        unchecked {
            meta.timestamp = uint64(block.timestamp);
            meta.l1Height = uint64(LibUtils.getBlockNumber() - 1);
            meta.l1Hash = LibUtils.getBlockHash(LibUtils.getBlockNumber() - 1);
            meta.mixHash = bytes32(block.difficulty * state.numBlocks);
        }

        MxcData.Block storage blk = state.blocks[state.numBlocks % config.ringBufferSize];

        blk.blockId = state.numBlocks;
        blk.proposedAt = meta.timestamp;
        blk.nextForkChoiceId = 1;
        blk.verifiedForkChoiceId = 0;

        blk.proposer = msg.sender;

        if (state.mxcTokenBalances[msg.sender] < uint256(state.blockFee) * 1e10) {
            revert L1_INSUFFICIENT_TOKEN();
        }

        unchecked {
            state.mxcTokenBalances[msg.sender] -= uint256(state.blockFee) * 1e10;
            state.totalStakeMxcTokenBalances -= uint256(state.blockFee) * 1e10;
            state.accBlockFees += state.blockFee;
            state.accProposedAt += meta.timestamp;
        }

        if (input.gasLimit < 21000) {
            input.gasLimit = 21000;
        }
        uint256 ethMxcPrice = 90000;
        {
            address oracle = resolver.resolve("oracle_ethmxc", true);
            if (oracle != address(0)) {
                ethMxcPrice = uint256(AggregatorInterface(oracle).latestAnswer());
                if (ethMxcPrice == 0) {
                    ethMxcPrice = 90000;
                }
            }
        }
        if (uint256(estimateGas) < gasStart) {
            estimateGas = uint128(gasStart);
        }
        // baseFee relay on arbitrum
        meta.baseFee = (block.basefee * uint256(estimateGas) * ethMxcPrice / input.gasLimit) / 1 gwei;

        if (state.prevBaseFee != 0) {
            if (meta.baseFee > (state.prevBaseFee * 105) / 100) {
                meta.baseFee = (state.prevBaseFee * 105) / 100;
            } else if (meta.baseFee < (state.prevBaseFee * 95) / 100) {
                meta.baseFee = (state.prevBaseFee * 95) / 100;
            }
            // min 3000 gwei
        }
        if (meta.baseFee < 3000) {
            meta.baseFee = 3000;
        }
        state.prevBaseFee = uint48(meta.baseFee);

        meta.baseFee = meta.baseFee * 1 gwei;

        meta.gasLimit = uint32(config.blockMaxGasLimit);
        blk.metaHash = LibUtils.hashMetadata(meta);
        emit BlockProposed(state.numBlocks, meta, state.blockFee);
        emit BlockProposeReward(state.numBlocks, meta.beneficiary, proposeReward);
        unchecked {
            ++state.numBlocks;
        }
    }

    function getBlock(MxcData.State storage state, MxcData.Config memory config, uint256 blockId)
        internal
        view
        returns (MxcData.Block storage blk)
    {
        blk = state.blocks[blockId % config.ringBufferSize];
        if (blk.blockId != blockId) revert L1_BLOCK_ID();
    }

    function _validateBlock(
        MxcData.State storage state,
        MxcData.Config memory config,
        MxcData.BlockMetadataInput memory input,
        bytes memory txList,
        uint256 txListLength
    ) private view returns (uint8 cacheTxListInfo) {
        if (
            input.beneficiary == address(0) || input.gasLimit == 0
                || input.gasLimit > config.blockMaxGasLimit
        ) revert L1_INVALID_METADATA();

        if (state.numBlocks >= state.lastVerifiedBlockId + config.maxNumProposedBlocks + 1) {
            revert L1_TOO_MANY_BLOCKS();
        }

        uint64 timeNow = uint64(block.timestamp);
        // handling txList
        {
            uint24 size = uint24(txListLength);
            if (size > config.maxBytesPerTxList) revert L1_TX_LIST();

            if (input.txListByteStart > input.txListByteEnd) {
                revert L1_TX_LIST_RANGE();
            }

            if (config.txListCacheExpiry == 0) {
                // caching is disabled
                if (input.txListByteStart != 0 || input.txListByteEnd != size) {
                    revert L1_TX_LIST_RANGE();
                }
            } else {
                // caching is enabled
                if (size == 0) {
                    // This blob shall have been submitted earlier
                    MxcData.TxListInfo memory info = state.txListInfo[input.txListHash];

                    if (input.txListByteEnd > info.size) {
                        revert L1_TX_LIST_RANGE();
                    }

                    if (info.size == 0 || info.validSince + config.txListCacheExpiry < timeNow) {
                        revert L1_TX_LIST_NOT_EXIST();
                    }
                } else {
                    if (input.txListByteEnd > size) revert L1_TX_LIST_RANGE();
//                    if (input.txListHash != keccak256(txList)) {
//                        revert L1_TX_LIST_HASH();
//                    }
                    // CHANGE(MXC): verified on MXC DA Service

                    cacheTxListInfo = input.cacheTxListInfo;
                }
            }
        }
    }
}
