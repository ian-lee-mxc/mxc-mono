// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {MxcL1} from "../../L1/MxcL1.sol";
import {MxcData} from "../../L1/MxcData.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract TestMxcL1EnableTokenomics is MxcL1 {
    function getConfig() public pure override returns (MxcData.Config memory config) {
        config.chainId = 5167003;
        // up to 2048 pending blocks
        config.maxNumProposedBlocks = 6;
        config.ringBufferSize = 8;
        // This number is calculated from maxNumProposedBlocks to make
        // the 'the maximum value of the multiplier' close to 20.0
        config.maxVerificationsPerTx = 0; // dont verify blocks automatically
        config.blockMaxGasLimit = 30000000;
        config.maxTransactionsPerBlock = 20;
        config.maxBytesPerTxList = 120000;
        config.minTxGasLimit = 21000;
    }
}
