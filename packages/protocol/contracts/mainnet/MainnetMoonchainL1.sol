// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../L1/TaikoL1.sol";
import "./addrcache/RollupAddressCache.sol";
import { IL1Staking } from "../team/staking/IL1Staking.sol";

/// @title MainnetMoonchainL1
/// @dev This contract shall be deployed to replace its parent contract on Arbitrum for Moonchain
/// mainnet to reduce gas cost.
/// @notice See the documentation in {MoonchainL1}.
/// @custom:security-contact luanxu@mxc.org
contract MainnetMoonchainL1 is TaikoL1, RollupAddressCache {
    uint256[51] private __gap;

    /// @inheritdoc ITaikoL1
    function getConfig() public pure virtual override returns (TaikoData.Config memory) {
        // All hard-coded configurations:
        // - treasury: the actual TaikoL2 address.
        // - anchorGasLimit: 250_000 (based on internal devnet, its ~220_000
        // after 256 L2 blocks)
        return TaikoData.Config({
            chainId: LibNetwork.MOONCHAIN,
            // If we have 1 block per 12 seconds, then each day there will be 86400/12=7200 blocks.
            // We therefore use 7200 as the base unit to configure blockMaxProposals and
            // blockRingBufferSize.
            blockMaxProposals: 3_240_000, // = 7200 * 45
            // We give 7200 * 5 = 36000 slots for verifeid blocks in case third party apps will use
            // their data.
            blockRingBufferSize: 3_600_000, // = 7200 * 50
            maxBlocksToVerify: 16,
            blockMaxGasLimit: 240_000_000,
            livenessBond: 0, // 125 Taiko token
            stateRootSyncInternal: 16,
            maxAnchorHeightOffset: 64,
            baseFeeConfig: TaikoData.BaseFeeConfig({
                adjustmentQuotient: 8,
                sharingPctg: 75,
                gasIssuancePerSecond: 5_000_000,
                minGasExcess: 1_340_000_000, // correspond to 0.008847185 gwei basefee
                maxGasIssuancePerBlock: 600_000_000 // two minutes
             }),
            ontakeForkHeight: 755_879
        });
    }

    /// @inheritdoc ITaikoL1
    /// @dev CHANGE(MOONCHAIN): This function is overriden to add the staking deposit reward call.
    function proposeBlockV2(
        bytes calldata _params,
        bytes calldata _txList
    )
        external
        override
        onlyFromOptionalNamed(LibStrings.B_BLOCK_PROPOSER)
        whenNotPaused
        nonReentrant
        emitEventForClient
        returns (TaikoData.BlockMetadataV2 memory meta_)
    {
        TaikoData.Config memory config = getConfig();
        (, meta_) = LibProposing.proposeBlock(state, config, this, _params, _txList);
        if (meta_.id < config.ontakeForkHeight) revert L1_FORK_ERROR();
        IL1Staking(resolve(LibStrings.B_STAKING, false)).stakingDepositReward();
    }

    /// @inheritdoc ITaikoL1
    /// @dev CHANGE(MOONCHAIN): This function is overriden to add the staking deposit reward call.
    function proposeBlocksV2(
        bytes[] calldata _paramsArr,
        bytes[] calldata _txListArr
    )
        external
        override
        onlyFromOptionalNamed(LibStrings.B_BLOCK_PROPOSER)
        whenNotPaused
        nonReentrant
        emitEventForClient
        returns (TaikoData.BlockMetadataV2[] memory metaArr_)
    {
        TaikoData.Config memory config = getConfig();
        (, metaArr_) = LibProposing.proposeBlocks(state, config, this, _paramsArr, _txListArr);
        for (uint256 i; i < metaArr_.length; ++i) {
            if (metaArr_[i].id < config.ontakeForkHeight) revert L1_FORK_ERROR();
        }
        IL1Staking(resolve(LibStrings.B_STAKING, false)).stakingDepositReward();
    }

    function _getAddress(uint64 _chainId, bytes32 _name) internal view override returns (address) {
        return getAddress(_chainId, _name, super._getAddress);
    }
}
