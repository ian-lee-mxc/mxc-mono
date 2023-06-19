pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "../common/Proxied.sol";
import "./AddressManager.sol";
import "./EssentialContract.sol";


contract EthMxcPriceAggregator is EssentialContract, AggregatorInterface {

    int256 public value;

    function initialize(address _addressManager, int _vaule) external initializer {
        EssentialContract._init(_addressManager);
    }

    function setValue(int _vault) external onlyOwner {
        value = _vault;
    }

    function latestAnswer() public view returns (int256) {
        return int256(value);
    }

    function latestTimestamp() external view returns(uint256) {
        return block.timestamp;
    }

    function latestRound() external view returns (uint256) {
        return uint256(1);
    }

    function getAnswer(uint256 roundId) external view returns (int256) {
        return int256(value);
    }

    function getTimestamp(uint256 roundId) external view returns (uint256) {
        return block.timestamp;
    }
}

contract ProxiedEthMxcPriceAggregator is Proxied, EthMxcPriceAggregator {}