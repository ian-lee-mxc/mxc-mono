// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {ISignalService} from "../../signal/ISignalService.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {LibUtils} from "./LibUtils.sol";
import {SafeCastUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MxcData} from "../../L1/MxcData.sol";

library LibVerifying {
    using SafeCastUpgradeable for uint256;
    using LibUtils for MxcData.State;

    event BlockVerified(uint256 indexed id, bytes32 blockHash, uint256 reward);
    event BlockVerifiedReward(uint256 indexed id, address prover,  uint256 reward);


    event CrossChainSynced(uint256 indexed srcHeight, bytes32 blockHash, bytes32 signalRoot);

    error L1_INVALID_CONFIG();

    function init(
        MxcData.State storage state,
        MxcData.Config memory config,
        bytes32 genesisBlockHash,
        uint64 initBlockFee,
        uint64 initProofTimeTarget,
        uint64 initProofTimeIssued,
        uint16 adjustmentQuotient
    ) internal {
        if (
            config.chainId <= 1 || config.maxNumProposedBlocks == 1
                || config.ringBufferSize <= config.maxNumProposedBlocks + 1
                || config.blockMaxGasLimit == 0 || config.maxTransactionsPerBlock == 0
                || config.maxBytesPerTxList == 0
            // EIP-4844 blob size up to 128K
            || config.maxBytesPerTxList > 128 * 1024 || config.maxEthDepositsPerBlock == 0
                || config.maxEthDepositsPerBlock < config.minEthDepositsPerBlock
            // EIP-4844 blob deleted after 30 days
            || config.txListCacheExpiry > 30 * 24 hours || config.ethDepositGas == 0
                || config.ethDepositMaxFee == 0 || config.ethDepositMaxFee >= type(uint96).max
                || adjustmentQuotient == 0 || initProofTimeTarget == 0 || initProofTimeIssued == 0
        ) revert L1_INVALID_CONFIG();

        uint64 timeNow = uint64(block.timestamp);
        state.genesisHeight = uint64(LibUtils.getBlockNumber());
        state.genesisTimestamp = timeNow;

        state.blockFee = initBlockFee;
        state.proofTimeIssued = initProofTimeIssued;
        state.proofTimeTarget = initProofTimeTarget;
        state.adjustmentQuotient = adjustmentQuotient;
        state.numBlocks = 1;

        MxcData.Block storage blk = state.blocks[0];
        blk.proposedAt = timeNow;
        blk.nextForkChoiceId = 2;
        blk.verifiedForkChoiceId = 1;

        MxcData.ForkChoice storage fc = state.blocks[0].forkChoices[1];
        fc.blockHash = genesisBlockHash;
        fc.provenAt = timeNow;

        emit BlockVerified(0, genesisBlockHash, 0);
    }

    function verifyBlocks(
        MxcData.State storage state,
        MxcData.Config memory config,
        AddressResolver resolver,
        uint256 maxBlocks
    ) internal {
        uint256 i = state.lastVerifiedBlockId;
        MxcData.Block storage blk = state.blocks[i % config.ringBufferSize];

        uint256 fcId = blk.verifiedForkChoiceId;
        assert(fcId > 0);
        bytes32 blockHash = blk.forkChoices[fcId].blockHash;
        uint32 gasUsed = blk.forkChoices[fcId].gasUsed;
        bytes32 signalRoot;

        uint64 processed;
        unchecked {
            ++i;
        }

        address systemProver = resolver.resolve("system_prover", true);
        while (i < state.numBlocks && processed < maxBlocks) {
            blk = state.blocks[i % config.ringBufferSize];
            assert(blk.blockId == i);

            fcId = LibUtils.getForkChoiceId(state, blk, blockHash, gasUsed);

            if (fcId == 0) break;

            MxcData.ForkChoice storage fc = blk.forkChoices[fcId];

            if (fc.prover == address(0)) break;

            uint256 proofCooldownPeriod = fc.prover == address(1)
                ? config.systemProofCooldownPeriod
                : config.proofCooldownPeriod;

            if (block.timestamp < fc.provenAt + proofCooldownPeriod) break;

            blockHash = fc.blockHash;
            gasUsed = fc.gasUsed;
            signalRoot = fc.signalRoot;

            _markBlockVerified({
                resolver: resolver,
                state: state,
                config: config,
                blk: blk,
                fcId: uint24(fcId),
                fc: fc,
                systemProver: systemProver
            });

            unchecked {
                ++i;
                ++processed;
            }
        }

        if (processed > 0) {
            unchecked {
                state.lastVerifiedBlockId += processed;
            }

            if (config.relaySignalRoot) {
                // Send the L2's signal root to the signal service so other MxcL1
                // deployments, if they share the same signal service, can relay the
                // signal to their corresponding MxcL2 contract.
                ISignalService(resolver.resolve("signal_service", false)).sendSignal(signalRoot);
            }
            emit CrossChainSynced(state.lastVerifiedBlockId, blockHash, signalRoot);
        }
    }

    function _markBlockVerified(
        AddressResolver resolver,
        MxcData.State storage state,
        MxcData.Config memory config,
        MxcData.Block storage blk,
        MxcData.ForkChoice storage fc,
        uint24 fcId,
        address systemProver
    ) private {
        uint64 proofTime;
        unchecked {
            proofTime = uint64(fc.provenAt - blk.proposedAt);
        }

        uint256 reward = LibTokenomics.getProofReward(resolver, config, state, proofTime);

        (state.proofTimeIssued, state.blockFee) =
            LibTokenomics.getNewBlockFeeAndProofTimeIssued(state, proofTime);

        unchecked {
            // CHANGE(MXC): MXC reward not part of blockFee
            state.accBlockFees -= state.blockFee;
            state.accProposedAt -= blk.proposedAt;
            state.mxcTokenBalances[address(1)] += reward;
        }

        LibTokenomics.mintReward(resolver,reward);

        blk.nextForkChoiceId = 1;
        blk.verifiedForkChoiceId = fcId;

        emit BlockVerified(blk.blockId, fc.blockHash, reward);
        emit BlockVerifiedReward(blk.blockId, fc.prover, reward);
    }
}
