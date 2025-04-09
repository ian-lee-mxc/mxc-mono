// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../L2/TaikoL2.sol";

contract MainnetMoonchainL2 is TaikoL2 {
    uint256 public constant FORK_HEIGHT = 0;
    /// @notice Tells if we need to validate basefee (for simulation).
    /// @return Returns true to skip checking basefee mismatch.

    function skipFeeCheck() public pure override returns (bool) {
        return false;
    }
}
