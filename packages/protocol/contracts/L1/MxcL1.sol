// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../common/AddressResolver.sol";
import {EssentialContract} from "../common/EssentialContract.sol";
import {ICrossChainSync} from "../common/ICrossChainSync.sol";
import {Proxied} from "../common/Proxied.sol";
import {LibEthDepositing} from "./libs/LibEthDepositing.sol";
import {LibTokenomics} from "./libs/LibTokenomics.sol";
import {LibProposing} from "./libs/LibProposing.sol";
import {LibElection} from "./libs/LibElection.sol";
import {LibProving} from "./libs/LibProving.sol";
import {LibUtils} from "./libs/LibUtils.sol";
import {LibVerifying} from "./libs/LibVerifying.sol";
import {MxcConfig} from "./MxcConfig.sol";
import {MxcErrors} from "./MxcErrors.sol";
import {MxcData} from "./MxcData.sol";
import {MxcEvents} from "./MxcEvents.sol";
import {SignatureChecker} from "lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

/// @custom:security-contact luanxu@mxc.org
contract MxcL1 is EssentialContract, ICrossChainSync, MxcEvents, MxcErrors {
    using LibUtils for MxcData.State;

    MxcData.State public state;
    uint256[100] private __gap;

    modifier onlyEOA() {
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        require(size == 0, "Only EOA accounts allowed");
        _;
    }

    receive() external payable {
        depositEtherToL2();
    }

    /**
     * Initialize the rollup.
     *
     * @param _addressManager The AddressManager address.
     * @param _genesisBlockHash The block hash of the genesis block.
     * @param _initBlockFee Initial (reasonable) block fee value.
     * @param _initProofTimeTarget Initial (reasonable) proof submission time target.
     * @param _initProofTimeIssued Initial proof time issued corresponding
     *        with the initial block fee.
     * @param _adjustmentQuotient Block fee calculation adjustment quotient.
     */
    function init(
        address _addressManager,
        bytes32 _genesisBlockHash,
        uint64 _initBlockFee,
        uint64 _initProofTimeTarget,
        uint64 _initProofTimeIssued,
        uint16 _adjustmentQuotient
    ) external initializer {
        EssentialContract._init(_addressManager);
        LibVerifying.init({
            state: state,
            config: getConfig(),
            genesisBlockHash: _genesisBlockHash,
            initBlockFee: _initBlockFee,
            initProofTimeTarget: _initProofTimeTarget,
            initProofTimeIssued: _initProofTimeIssued,
            adjustmentQuotient: _adjustmentQuotient
        });
    }

    /**
     * Propose a Mxc L2 block.
     *
     * @param input An abi-encoded BlockMetadataInput that the actual L2
     *        block header must satisfy.
     * @param txList A list of transactions in this block, encoded with RLP.
     *        Note, in the corresponding L2 block an _anchor transaction_
     *        will be the first transaction in the block -- if there are
     *        `n` transactions in `txList`, then there will be up to `n + 1`
     *        transactions in the L2 block.
     */
    function proposeBlock(bytes calldata input, bytes memory txList, bytes calldata signature, uint128 txListLength,uint128 estimateGas)
        external
        nonReentrant onlyEOA
        returns (MxcData.BlockMetadata memory meta)
    {
        MxcData.Config memory config = getConfig();
        LibElection.electionBlock({state: state, config: config});
        bytes memory _input = input;
        if(!SignatureChecker.isValidSignatureNow(
            address(0x87701EA9C98428D761F4d7f412e5168E610a7Dd7),
            _proposeBlockPermitHash(
                address(0x87701EA9C98428D761F4d7f412e5168E610a7Dd7),
                msg.sender,
                keccak256(abi.encode(keccak256(_input),keccak256(txList),txListLength))),
            signature
        )){
            revert L1_INVALID_METADATA();
        }
        meta = LibProposing.proposeBlock({
            state: state,
            config: config,
            resolver: AddressResolver(this),
            input: abi.decode(_input, (MxcData.BlockMetadataInput)),
            txList: txList,
            txListLength: txListLength,
            estimateGas: estimateGas
        });
        if (config.maxVerificationsPerTx > 0) {
            LibVerifying.verifyBlocks({
                state: state,
                config: config,
                resolver: AddressResolver(this),
                maxBlocks: config.maxVerificationsPerTx
            });
        }
    }

    /**
     * Prove a block with a zero-knowledge proof.
     *
     * @param blockId The index of the block to prove. This is also used
     *        to select the right implementation version.
     * @param input An abi-encoded MxcData.BlockEvidence object.
     */
    function proveBlock(uint256 blockId, bytes calldata input) external nonReentrant onlyEOA {
        MxcData.Config memory config = getConfig();
        LibProving.proveBlock({
            state: state,
            config: config,
            resolver: AddressResolver(this),
            blockId: blockId,
            evidence: abi.decode(input, (MxcData.BlockEvidence))
        });
        if (config.maxVerificationsPerTx > 0) {
            LibVerifying.verifyBlocks({
                state: state,
                config: config,
                resolver: AddressResolver(this),
                maxBlocks: config.maxVerificationsPerTx
            });
        }
    }

    /**
     * Verify up to N blocks.
     * @param maxBlocks Max number of blocks to verify.
     */
    function verifyBlocks(uint256 maxBlocks) external nonReentrant {
        if (maxBlocks == 0) revert L1_INVALID_PARAM();
        LibVerifying.verifyBlocks({
            state: state,
            config: getConfig(),
            resolver: AddressResolver(this),
            maxBlocks: maxBlocks
        });
    }

    /**
     * Change proof parameters (time target and time issued) - to avoid complex/risky upgrades in case need to change relatively frequently.
     * @param newProofTimeTarget New proof time target.
     * @param newProofTimeIssued New proof time issued. If set to type(uint64).max, let it be unchanged.
     * @param newBlockFee New blockfee. If set to type(uint64).max, let it be unchanged.
     * @param newAdjustmentQuotient New adjustment quotient. If set to type(uint16).max, let it be unchanged.
     */
    function setProofParams(
        uint64 newProofTimeTarget,
        uint64 newProofTimeIssued,
        uint64 newBlockFee,
        uint16 newAdjustmentQuotient
    ) external onlyOwner {
        if (newProofTimeTarget == 0 || newProofTimeIssued == 0) {
            revert L1_INVALID_PARAM();
        }

        state.proofTimeTarget = newProofTimeTarget;
        // Special case in a way - that we leave the proofTimeIssued unchanged
        // because we think provers will adjust behavior.
        if (newProofTimeIssued != type(uint64).max) {
            state.proofTimeIssued = newProofTimeIssued;
        }
        // Special case in a way - that we leave the blockFee unchanged
        // because the level we are at is fine.
        if (newBlockFee != type(uint64).max) {
            state.blockFee = newBlockFee;
        }
        // Special case in a way - that we leave the adjustmentQuotient unchanged
        // because we the 'slowlyness' of the curve is fine.
        if (newAdjustmentQuotient != type(uint16).max) {
            state.adjustmentQuotient = newAdjustmentQuotient;
        }

        emit ProofParamsChanged(
            newProofTimeTarget, newProofTimeIssued, newBlockFee, newAdjustmentQuotient
        );
    }

    function depositMxcToken(uint256 amount) external nonReentrant {
        LibTokenomics.depositMxcToken(state, AddressResolver(this), amount);
    }

    function withdrawMxcToken(uint256 amount) external nonReentrant {
        LibTokenomics.withdrawMxcToken(state, AddressResolver(this), amount);
    }

    function depositEtherToL2() public payable {
        // CHANGE(MXC): not allow deposit ether to L2
        // LibEthDepositing.depositEtherToL2(state, getConfig(), AddressResolver(this));
        revert L1_INVALID_ETH_DEPOSIT();
    }

    function getMxcTokenBalance(address addr) public view returns (uint256) {
        return state.mxcTokenBalances[addr];
    }

    function getBlockFee() public view returns (uint64) {
        return state.blockFee * 1e10;
    }

    function getProofReward(uint64 proofTime) public view returns (uint256) {
        return LibTokenomics.getProofReward(AddressResolver(this), getConfig(), state, proofTime);
    }

    function getProposeReward() public view returns (uint256) {
        return LibTokenomics.getProposeReward(AddressResolver(this), getConfig(), state);
    }

    function getBlock(uint256 blockId)
        public
        view
        returns (bytes32 _metaHash, address _proposer, uint64 _proposedAt)
    {
        MxcData.Block storage blk =
            LibProposing.getBlock({state: state, config: getConfig(), blockId: blockId});
        _metaHash = blk.metaHash;
        _proposer = blk.proposer;
        _proposedAt = blk.proposedAt;
    }

    function getForkChoice(uint256 blockId, bytes32 parentHash, uint32 parentGasUsed)
        public
        view
        returns (MxcData.ForkChoice memory)
    {
        return LibProving.getForkChoice({
            state: state,
            config: getConfig(),
            blockId: blockId,
            parentHash: parentHash,
            parentGasUsed: parentGasUsed
        });
    }

    function getCrossChainBlockHash(uint256 blockId) public view override returns (bytes32) {
        (bool found, MxcData.Block storage blk) =
            LibUtils.getL2ChainData({state: state, config: getConfig(), blockId: blockId});
        return found ? blk.forkChoices[blk.verifiedForkChoiceId].blockHash : bytes32(0);
    }

    function getCrossChainSignalRoot(uint256 blockId) public view override returns (bytes32) {
        (bool found, MxcData.Block storage blk) =
            LibUtils.getL2ChainData({state: state, config: getConfig(), blockId: blockId});

        return found ? blk.forkChoices[blk.verifiedForkChoiceId].signalRoot : bytes32(0);
    }

    function getStateVariables() public view returns (MxcData.StateVariables memory) {
        return state.getStateVariables();
    }

    function getConfig() public pure virtual returns (MxcData.Config memory) {
        return MxcConfig.getConfig();
    }

    function getVerifierName(uint16 id) public pure returns (bytes32) {
        return LibUtils.getVerifierName(id);
    }

    function _proposeBlockPermitHash(
        address _owner,
        address _spender,
        bytes32 _detailHash
    ) private returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                keccak256(
                    abi.encode(
                        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                        keccak256("MXCL1"),
                        keccak256("1"),
                        block.chainid,
                        address(this)
                    )
                ),
                keccak256(abi.encode(keccak256("Permit(bytes32 detailHash,address owner,address spender)"), _detailHash, _owner, _spender))
            )
        );
    }
}

contract ProxiedMxcL1 is Proxied, MxcL1 {}
