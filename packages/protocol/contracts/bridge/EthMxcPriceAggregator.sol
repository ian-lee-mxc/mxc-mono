// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IAggregatorInterface.sol";

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "../common/ControllableUpgradeable.sol";

contract EthMxcPriceAggregator is UUPSUpgradeable, ControllableUpgradeable, IAggregatorInterface {
    int256 public value;

    constructor(int256 _value) {
        value = _value;
    }

    function init(int256 _value) public initializer {
        __Controllable_init();
        value = _value;
    }

    function setValue(int256 _vault) external onlyController {
        value = _vault;
    }

    function latestAnswer() public view returns (int256) {
        return int256(value);
    }

    function latestTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function latestRound() external view returns (uint256) {
        return uint256(1);
    }

    function getAnswer(uint256) external view returns (int256) {
        return int256(value);
    }

    function getTimestamp(uint256) external view returns (uint256) {
        return block.timestamp;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        return;
    }
}
