// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {LibMath} from "../../libs/LibMath.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {SafeCastUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MxcData} from "../MxcData.sol";

interface ArbSys {
    /**
     * @notice Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)
     * @return block number as int
     */
    function arbBlockNumber() external view returns (uint256);

    function arbBlockHash(uint256 blockNumber) external view returns (bytes32);
}

library LibUtils {
    using LibMath for uint256;

    error L1_BLOCK_ID();

    function getL2ChainData(
        MxcData.State storage state,
        MxcData.Config memory config,
        uint256 blockId
    ) internal view returns (bool found, MxcData.Block storage blk) {
        uint256 id = blockId == 0 ? state.lastVerifiedBlockId : blockId;
        blk = state.blocks[id % config.ringBufferSize];
        found = (blk.blockId == id && blk.verifiedForkChoiceId != 0);
    }

    function getForkChoiceId(
        MxcData.State storage state,
        MxcData.Block storage blk,
        bytes32 parentHash,
        uint32 parentGasUsed
    ) internal view returns (uint256 fcId) {
        if (blk.forkChoices[1].key == keyForForkChoice(parentHash, parentGasUsed)) {
            fcId = 1;
        } else {
            fcId = state.forkChoiceIds[blk.blockId][parentHash][parentGasUsed];
        }

        if (fcId >= blk.nextForkChoiceId) {
            fcId = 0;
        }
    }

    function getStateVariables(MxcData.State storage state)
        internal
        view
        returns (MxcData.StateVariables memory)
    {
        return MxcData.StateVariables({
            blockFee: state.blockFee,
            accBlockFees: state.accBlockFees,
            genesisHeight: state.genesisHeight,
            genesisTimestamp: state.genesisTimestamp,
            numBlocks: state.numBlocks,
            proofTimeIssued: state.proofTimeIssued,
            proofTimeTarget: state.proofTimeTarget,
            lastVerifiedBlockId: state.lastVerifiedBlockId,
            accProposedAt: state.accProposedAt,
            nextEthDepositToProcess: state.nextEthDepositToProcess,
            numEthDeposits: uint64(state.ethDeposits.length)
        });
    }

    function movingAverage(uint256 maValue, uint256 newValue, uint256 maf)
        internal
        pure
        returns (uint256)
    {
        if (maValue == 0) {
            return newValue;
        }
        uint256 _ma = (maValue * (maf - 1) + newValue) / maf;
        return _ma > 0 ? _ma : maValue;
    }

    function hashMetadata(MxcData.BlockMetadata memory meta) internal pure returns (bytes32 hash) {
        uint256[7] memory inputs;

        inputs[0] = (uint256(meta.id) << 192) | (uint256(meta.timestamp) << 128)
            | (uint256(meta.l1Height) << 64);

        inputs[1] = uint256(meta.l1Hash);
        inputs[2] = uint256(meta.mixHash);
        inputs[3] = uint256(meta.depositsRoot);
        inputs[4] = uint256(meta.txListHash);

        inputs[5] = (uint256(meta.txListByteStart) << 232) | (uint256(meta.txListByteEnd) << 208)
            | (uint256(meta.gasLimit) << 176) | (uint256(uint160(meta.beneficiary)) << 16)
            | (uint256(meta.cacheTxListInfo) << 8);

        inputs[6] = (uint256(uint160(meta.treasury)) << 96);

        // Ignoring `meta.depositsProcessed` as `meta.depositsRoot`
        // is a hash of it.

        assembly {
            hash := keccak256(inputs, mul(7, 32))
        }
    }

    function keyForForkChoice(bytes32 parentHash, uint32 parentGasUsed)
        internal
        pure
        returns (bytes32 key)
    {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, parentGasUsed)
            mstore(add(ptr, 32), parentHash)
            key := keccak256(add(ptr, 28), 36)
            mstore(0x40, add(ptr, 64))
        }
    }

    function getVerifierName(uint16 id) internal pure returns (bytes32) {
        return bytes32(uint256(0x1000000) + id);
    }

    function getBlockNumber() internal view returns (uint256 blockNumber) {
        blockNumber = ArbSys(address(100)).arbBlockNumber();
    }

    function getBlockHash(uint256 blockNumber) internal view returns (bytes32 L1BlockHash) {
        L1BlockHash = ArbSys(address(100)).arbBlockHash(blockNumber);
    }
}
