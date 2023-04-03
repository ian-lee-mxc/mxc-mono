// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {MXCToken} from "../../L1/MXCToken.sol";

contract TestMXCToken is MXCToken {
    function mintAnyone(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
