// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {MxcData} from "../L1/MxcData.sol";

library MxcConfig {
    function getConfig() internal pure returns (MxcData.Config memory) {
        return MxcData.Config({
            chainId: 18686,
            // Two weeks if avg block time is 12 seconds
            maxNumProposedBlocks: 100800,
            ringBufferSize: 100800 + 10,
            // Each time one more block is verified, there will be ~20k
            // more gas cost.
            maxVerificationsPerTx: 10,
            // Set it to 6M, since its the upper limit of the Alpha-3
            // testnet's circuits.
            blockMaxGasLimit: 6000000,
            // Set it to 79  (+1 MxcL2.anchor transaction = 80),
            // and 80 is the upper limit of the Alpha-2 testnet's circuits.
            maxTransactionsPerBlock: 79,
            minEthDepositsPerBlock: 1,
            maxEthDepositsPerBlock: 32,
            maxEthDepositAmount: 10000 ether,
            minEthDepositAmount: 0.1 ether,
            // Set it to 120KB, since 128KB is the upper size limit
            // of a geth transaction, so using 120KB for the proposed
            // transactions list calldata, 8K for the remaining tx fields.
            maxBytesPerTxList: 120000,
            proofCooldownPeriod: 2 hours,
            systemProofCooldownPeriod: 1 hours,
            // Only need 1 real zkp per 10 blocks.
            // If block number is N, then only when N % 10 == 0, the real ZKP
            // is needed. For mainnet, this must be 0 or 1.
            realProofSkipSize: 0,
            ethDepositGas: 21000,
            ethDepositMaxFee: 1 ether / 10,
            txListCacheExpiry: 0,
            relaySignalRoot: false
        });
    }
}
