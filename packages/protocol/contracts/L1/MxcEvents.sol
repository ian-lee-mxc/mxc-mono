// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {MxcData} from "./MxcData.sol";

abstract contract MxcEvents {
    // The following events must match the definitions in corresponding L1 libraries.
    event BlockProposed(uint256 indexed id, MxcData.BlockMetadata meta, uint64 blockFee);
    event BlockProposeReward(uint256 indexed id, address proposer, uint256 reward);

    event BlockProven(
        uint256 indexed id,
        bytes32 parentHash,
        bytes32 blockHash,
        bytes32 signalRoot,
        address prover,
        uint32 parentGasUsed
    );

    event BlockVerified(uint256 indexed id, bytes32 blockHash, uint256 reward);
    event BlockVerifiedReward(uint256 indexed id, address prover,  uint256 reward);

    event EthDeposited(MxcData.EthDeposit deposit);

    event ProofParamsChanged(
        uint64 proofTimeTarget, uint64 proofTimeIssued, uint64 blockFee, uint16 adjustmentQuotient
    );
}
