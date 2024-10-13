// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "../L1/TaikoL1.sol";
import "./addrcache/RollupAddressCache.sol";

/// @title MainnetTaikoL1
/// @dev This contract shall be deployed to replace its parent contract on Ethereum for Taiko
/// mainnet to reduce gas cost.
/// @notice See the documentation in {TaikoL1}.
/// @custom:security-contact security@taiko.xyz
contract GenevaMoonchainL1 is TaikoL1, RollupAddressCache {
    /// @inheritdoc ITaikoL1
    function getConfig() public pure override returns (TaikoData.Config memory) {
        // All hard-coded configurations:
        // - treasury: the actual TaikoL2 address.
        // - anchorGasLimit: 250_000 (based on internal devnet, its ~220_000
        // after 256 L2 blocks)
        return TaikoData.Config({
            chainId: LibNetwork.GENEVA,
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
            ontakeForkHeight: 501_303 // = 7200 * 52
         });
    }

    /// @notice CHANGE(MOONCHAIN): Reinitialize the contract.
    /// @param _owner The owner of this contract. msg.sender will be used if this value is zero.
    /// @param _rollupAddressManager The address of the {AddressManager} contract.
    /// @param _genesisBlockHash The block hash of the genesis block.
    /// @param _toPause true to pause the contract by default.
    function initMigrate(
        address _owner,
        address _rollupAddressManager,
        bytes32 _genesisBlockHash,
        uint64 _l2LatestHeight,
        bool _toPause
    )
        external
        reinitializer(2)
    {
        __Essential_init(_owner, _rollupAddressManager);
        doMigrate(_genesisBlockHash, _l2LatestHeight);
        if (_toPause) _pause();

        TaikoData.BlockParamsV2 memory params = TaikoData.BlockParamsV2(
            msg.sender,
            bytes32(uint256(1)),
            uint64(0),
            uint64(block.timestamp),
            uint32(0),
            uint32(0),
            uint8(0)
        );
        bytes memory _params = abi.encode(params);

        // upgrade TaikoL2 Contract
        // create implement
        LibProposing.proposeBlock(state, getConfig(), this, _params, "");
    }

    function proposeEmptyBlock() external {
        TaikoData.Config memory _config = getConfig();
        TaikoData.BlockParamsV2 memory params = TaikoData.BlockParamsV2(
            msg.sender,
            state.blocks[state.slotB.numBlocks - 1 % _config.blockRingBufferSize].metaHash,
            uint64(0),
            uint64(block.timestamp),
            uint32(0),
            uint32(0),
            uint8(0)
        );
        bytes memory _params = abi.encode(params);
        LibProposing.proposeBlock(state, getConfig(), this, _params, "");
        // upgrade TaikoL2 Contract
        // create implement
    }

    function doMigrate(bytes32 _genesisBlockHash, uint64 _l2LatestHeight) private {
        TaikoData.Config memory _config = getConfig();
        // Init state
        state.slotA.genesisHeight = uint64(26_862_041);
        state.slotA.genesisTimestamp = uint64(1_716_613_430);
        state.slotB.numBlocks = _l2LatestHeight + 1;
        state.slotB.lastVerifiedBlockId = _l2LatestHeight;
        TaikoData.SlotB memory b = state.slotB;

        state.blocks[0].nextTransitionId = 1;
        state.blocks[0].blockId = 0;
        state.blocks[0].verifiedTransitionId = 1;
        state.transitions[0][1].blockHash = _genesisBlockHash;

        TaikoData.BlockV2 storage blk =
            state.blocks[(b.numBlocks - 1) % _config.blockRingBufferSize];
        blk.metaHash = bytes32(uint256(1));
        blk.blockId = _l2LatestHeight;
        blk.proposedIn = _l2LatestHeight;
        blk.verifiedTransitionId = 1;
        blk.nextTransitionId = 2;
        TaikoData.TransitionState storage ts =
            state.transitions[(b.numBlocks - 1) % _config.blockRingBufferSize][1];
        ts.blockHash = bytes32(uint256(1));
        ts.stateRoot = bytes32(uint256(1));
    }

    function _getAddress(uint64 _chainId, bytes32 _name) internal view override returns (address) {
        return getAddress(_chainId, _name, super._getAddress);
    }
}
