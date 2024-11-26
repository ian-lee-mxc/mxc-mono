// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../L2/TaikoL2.sol";

/// @title MainnetTaikoL1
/// @dev This contract shall be deployed to replace its parent contract on Ethereum for Taiko
/// mainnet to reduce gas cost.
/// @notice See the documentation in {TaikoL1}.
/// @custom:security-contact security@taiko.xyz
contract MainnetMoonchainL2 is TaikoL2 {
    function initMoonchain(
        address _owner,
        address _addressManager,
        uint64 _l1ChainId,
        uint64 _gasExcess
    )
        external
        reinitializer(3)
    {
        __Essential_init(_owner, _addressManager);
        l1ChainId = _l1ChainId;
        parentTimestamp = uint64(block.timestamp);
        parentGasExcess = _gasExcess;
        parentGasTarget = 0;
        (publicInputHash,) = _calcPublicInputHash(block.number);
    }

    /// @notice Tells if we need to validate basefee (for simulation).
    /// @return Returns true to skip checking basefee mismatch.
    function skipFeeCheck() public pure override returns (bool) {
        return true;
    }
}
