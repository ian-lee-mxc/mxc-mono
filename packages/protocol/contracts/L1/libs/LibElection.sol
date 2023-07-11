// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibAddress} from "../../libs/LibAddress.sol";
import {LibEthDepositing} from "./LibEthDepositing.sol";
import {LibUtils} from "./LibUtils.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {SafeCastUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MxcData} from "../MxcData.sol";


library LibElection {
    error L1_ELECTION_INVALID_PROPOSER();
    error L1_ELECTION_SPEED();

    function electionBlock(
        MxcData.State storage state,
        MxcData.Config memory config
    ) internal {

        uint256 expectedBlockTime = 12;
        uint256 epochBlockNumber = 20;
        uint256 prevProposerAt = 0;
        if(state.numBlocks > 0) {
            prevProposerAt = state.blocks[(state.numBlocks - 1) % config.ringBufferSize].proposedAt;
        }
        if(block.timestamp < prevProposerAt + expectedBlockTime) {
            revert L1_ELECTION_SPEED();
        }
//        if (state.candidate.length > epochBlockNumber) {
//            uint256 electionIndex = state.numBlocks % epochBlockNumber;
//            address currentElection = state.proposerElections[electionIndex + state.proposerElectionTimeoutOffset];
//
//            if(currentElection == address(0)) {
//                executeElection(state, epochBlockNumber, true);
//                electionIndex = 0;
//                currentElection = msg.sender;
//            }
//
//            // timeout offset
//            uint offset = (block.timestamp - prevProposerAt) / expectedBlockTime;
//            if(offset > 0){
//                currentElection = state.proposerElections[(electionIndex + state.proposerElectionTimeoutOffset + offset) % epochBlockNumber];
//            }
//
//            if (currentElection != msg.sender) {
//                revert L1_ELECTION_INVALID_PROPOSER();
//            }
//
//            // reach end of epoch
//            if(state.proposerElectionTimeoutOffset >= epochBlockNumber) {
//                executeElection(state, epochBlockNumber, false);
//                state.proposerElectionTimeoutOffset = 0;
//            }
//        }
    }

    function executeElection(
        MxcData.State storage state,
        uint256 epochBlockNumber,
        bool executor) internal {

        address[] memory candidates = state.candidate;
        uint256[] memory electionProbabilities = new uint256[](candidates.length);

        uint256 i;
        if(executor) {
            i = 1;
            state.proposerElections[0] = msg.sender;
        }

        // Election Probability
        for (uint i = 0; i < candidates.length; i++) {
            uint256 candidateDeposit = state.mxcTokenBalances[candidates[i]];
            electionProbabilities[i] = candidateDeposit / state.totalStakeMxcTokenBalances;
        }

        uint randomNum;
        uint256 cumulativeDeposits;
        bytes32 seed = LibUtils.getBlockHash(LibUtils.getBlockNumber());
        // Election candidates.
        for (i = 0; i < epochBlockNumber; i++) {
            // To select an election probability through weighted random selection method.
            randomNum = generateRandomNumber(seed, state.totalStakeMxcTokenBalances);
            for (uint256 j = 0; j < candidates.length; j++) {
                if(i == 0) {
                    cumulativeDeposits += state.mxcTokenBalances[candidates[j]];
                }
                if(candidates[j] == address(0)) {
                    continue;
                }
                if (cumulativeDeposits >= randomNum) {
                    state.proposerElections[i] = candidates[j];
                    candidates[j] = address(0);
                    break;
                }
                if(j == candidates.length - 1) {
                    revert("No candidate selected");
                }
            }
        }
    }

    function generateRandomNumber(bytes32 seed, uint256 maxValue) internal view returns (uint256) {
        bytes32 randomBytes = keccak256(abi.encodePacked(block.number, blockhash(block.number), seed));

        return uint256(randomBytes) % maxValue;
    }
}


