// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

contract ControllableUpgradeable is Ownable2StepUpgradeable {
    mapping(address => bool) public controllers;

    event ControllerChanged(address indexed controller, bool enabled);

    modifier onlyController() {
        require(controllers[msg.sender], "Controllable: Caller is not a controller");
        _;
    }

    function setController(address controller, bool enabled) public onlyOwner {
        controllers[controller] = enabled;
        emit ControllerChanged(controller, enabled);
    }

    function __Controllable_init() public onlyInitializing {
        controllers[msg.sender] = true;
        __Ownable_init();
    }
}
