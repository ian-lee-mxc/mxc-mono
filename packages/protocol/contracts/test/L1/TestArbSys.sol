
pragma solidity ^0.8.18;

interface ArbSys {
    /**
     * @notice Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)
     * @return block number as int
     */
    function arbBlockNumber() external view returns (uint);

    function arbBlockHash(uint256 blockNumber) external view returns (bytes32);
}

contract TestArbSys is ArbSys {
    function arbBlockNumber() external view returns (uint) {
        return block.number;
    }

    function arbBlockHash(uint256 blockNumber) external view returns (bytes32) {
        return blockhash(blockNumber);
    }
}
