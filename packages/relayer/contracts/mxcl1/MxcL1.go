// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package mxcl1

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// MxcDataBlockMetadata is an auto generated low-level Go binding around an user-defined struct.
type MxcDataBlockMetadata struct {
	Id                uint64
	Timestamp         uint64
	L1Height          uint64
	L1Hash            [32]byte
	MixHash           [32]byte
	TxListHash        [32]byte
	TxListByteStart   *big.Int
	TxListByteEnd     *big.Int
	GasLimit          uint32
	Beneficiary       common.Address
	Treasury          common.Address
	DepositsProcessed []MxcDataEthDeposit
	BaseFee           *big.Int
	BlockReward       *big.Int
}

// MxcDataConfig is an auto generated low-level Go binding around an user-defined struct.
type MxcDataConfig struct {
	ChainId                   *big.Int
	MaxNumProposedBlocks      *big.Int
	RingBufferSize            *big.Int
	MaxVerificationsPerTx     *big.Int
	BlockMaxGasLimit          uint64
	MaxTransactionsPerBlock   uint64
	MaxBytesPerTxList         uint64
	TxListCacheExpiry         *big.Int
	ProofCooldownPeriod       *big.Int
	SystemProofCooldownPeriod *big.Int
	RealProofSkipSize         *big.Int
	EthDepositGas             *big.Int
	EthDepositMaxFee          *big.Int
	MinEthDepositsPerBlock    uint64
	MaxEthDepositsPerBlock    uint64
	MaxEthDepositAmount       *big.Int
	MinEthDepositAmount       *big.Int
	RelaySignalRoot           bool
}

// MxcDataEthDeposit is an auto generated low-level Go binding around an user-defined struct.
type MxcDataEthDeposit struct {
	Recipient common.Address
	Amount    *big.Int
	Id        uint64
}

// MxcDataForkChoice is an auto generated low-level Go binding around an user-defined struct.
type MxcDataForkChoice struct {
	Key        [32]byte
	BlockHash  [32]byte
	SignalRoot [32]byte
	ProvenAt   uint64
	Prover     common.Address
	GasUsed    uint32
}

// MxcDataStateVariables is an auto generated low-level Go binding around an user-defined struct.
type MxcDataStateVariables struct {
	BlockFee                uint64
	AccBlockFees            uint64
	GenesisHeight           uint64
	GenesisTimestamp        uint64
	NumBlocks               uint64
	ProofTimeIssued         uint64
	ProofTimeTarget         uint64
	LastVerifiedBlockId     uint64
	AccProposedAt           uint64
	NextEthDepositToProcess uint64
	NumEthDeposits          uint64
}

// MxcL1MetaData contains all meta data concerning the MxcL1 contract.
var MxcL1MetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[],\"name\":\"L1_ALREADY_PROVEN\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_ALREADY_PROVEN\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_BLOCK_ID\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_BLOCK_ID\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_BLOCK_ID\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_DEPOSIT_REQUIREMENT\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_ELECTION_INVALID_PROPOSER\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_ELECTION_SPEED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_ELECTION_SPEED\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"expected\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"actual\",\"type\":\"bytes32\"}],\"name\":\"L1_EVIDENCE_MISMATCH\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"expected\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"actual\",\"type\":\"bytes32\"}],\"name\":\"L1_EVIDENCE_MISMATCH\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_FORK_CHOICE_NOT_FOUND\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_FORK_CHOICE_NOT_FOUND\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INSUFFICIENT_TOKEN\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INSUFFICIENT_TOKEN\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INSUFFICIENT_TOKEN\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INSUFFICIENT_TOKEN\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_CONFIG\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_CONFIG\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_ETH_DEPOSIT\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_EVIDENCE\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_EVIDENCE\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_METADATA\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_METADATA\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_PARAM\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_PROOF\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_PROOF\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_PROOF_OVERWRITE\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_INVALID_PROOF_OVERWRITE\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_NOT_SPECIAL_PROVER\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_NOT_SPECIAL_PROVER\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_NOT_UNLOCK\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_ORACLE_PROVER_DISABLED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_ORACLE_PROVER_DISABLED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_SAME_PROOF\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_SAME_PROOF\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_SYSTEM_PROVER_DISABLED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_SYSTEM_PROVER_DISABLED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_SYSTEM_PROVER_PROHIBITED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_SYSTEM_PROVER_PROHIBITED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TOO_MANY_BLOCKS\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TOO_MANY_BLOCKS\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST_HASH\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST_HASH\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST_NOT_EXIST\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST_NOT_EXIST\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST_RANGE\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"L1_TX_LIST_RANGE\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"Overflow\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"RESOLVER_DENIED\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"RESOLVER_INVALID_ADDR\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"chainId\",\"type\":\"uint256\"},{\"internalType\":\"bytes32\",\"name\":\"name\",\"type\":\"bytes32\"}],\"name\":\"RESOLVER_ZERO_ADDR\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"addressManager\",\"type\":\"address\"}],\"name\":\"AddressManagerChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"proposer\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"reward\",\"type\":\"uint256\"}],\"name\":\"BlockProposeReward\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"components\":[{\"internalType\":\"uint64\",\"name\":\"id\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"timestamp\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"l1Height\",\"type\":\"uint64\"},{\"internalType\":\"bytes32\",\"name\":\"l1Hash\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"mixHash\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"txListHash\",\"type\":\"bytes32\"},{\"internalType\":\"uint24\",\"name\":\"txListByteStart\",\"type\":\"uint24\"},{\"internalType\":\"uint24\",\"name\":\"txListByteEnd\",\"type\":\"uint24\"},{\"internalType\":\"uint32\",\"name\":\"gasLimit\",\"type\":\"uint32\"},{\"internalType\":\"address\",\"name\":\"beneficiary\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"treasury\",\"type\":\"address\"},{\"components\":[{\"internalType\":\"address\",\"name\":\"recipient\",\"type\":\"address\"},{\"internalType\":\"uint96\",\"name\":\"amount\",\"type\":\"uint96\"},{\"internalType\":\"uint64\",\"name\":\"id\",\"type\":\"uint64\"}],\"internalType\":\"structMxcData.EthDeposit[]\",\"name\":\"depositsProcessed\",\"type\":\"tuple[]\"},{\"internalType\":\"uint256\",\"name\":\"baseFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"blockReward\",\"type\":\"uint256\"}],\"indexed\":false,\"internalType\":\"structMxcData.BlockMetadata\",\"name\":\"meta\",\"type\":\"tuple\"},{\"indexed\":false,\"internalType\":\"uint64\",\"name\":\"blockFee\",\"type\":\"uint64\"}],\"name\":\"BlockProposed\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"parentHash\",\"type\":\"bytes32\"},{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"},{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"signalRoot\",\"type\":\"bytes32\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"prover\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint32\",\"name\":\"parentGasUsed\",\"type\":\"uint32\"}],\"name\":\"BlockProven\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"prover\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"reward\",\"type\":\"uint256\"}],\"name\":\"BlockProvenReward\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"reward\",\"type\":\"uint256\"}],\"name\":\"BlockVerified\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"srcHeight\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"},{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"signalRoot\",\"type\":\"bytes32\"}],\"name\":\"CrossChainSynced\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"recipient\",\"type\":\"address\"},{\"internalType\":\"uint96\",\"name\":\"amount\",\"type\":\"uint96\"},{\"internalType\":\"uint64\",\"name\":\"id\",\"type\":\"uint64\"}],\"indexed\":false,\"internalType\":\"structMxcData.EthDeposit\",\"name\":\"deposit\",\"type\":\"tuple\"}],\"name\":\"EthDeposited\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint8\",\"name\":\"version\",\"type\":\"uint8\"}],\"name\":\"Initialized\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"previousOwner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint64\",\"name\":\"proofTimeTarget\",\"type\":\"uint64\"},{\"indexed\":false,\"internalType\":\"uint64\",\"name\":\"proofTimeIssued\",\"type\":\"uint64\"},{\"indexed\":false,\"internalType\":\"uint64\",\"name\":\"blockFee\",\"type\":\"uint64\"},{\"indexed\":false,\"internalType\":\"uint16\",\"name\":\"adjustmentQuotient\",\"type\":\"uint16\"}],\"name\":\"ProofParamsChanged\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"addressManager\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"depositEtherToL2\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"depositMxcToken\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"blockId\",\"type\":\"uint256\"}],\"name\":\"getBlock\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"_metaHash\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"_proposer\",\"type\":\"address\"},{\"internalType\":\"uint64\",\"name\":\"_proposedAt\",\"type\":\"uint64\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBlockFee\",\"outputs\":[{\"internalType\":\"uint64\",\"name\":\"\",\"type\":\"uint64\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getConfig\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"chainId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"maxNumProposedBlocks\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ringBufferSize\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"maxVerificationsPerTx\",\"type\":\"uint256\"},{\"internalType\":\"uint64\",\"name\":\"blockMaxGasLimit\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"maxTransactionsPerBlock\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"maxBytesPerTxList\",\"type\":\"uint64\"},{\"internalType\":\"uint256\",\"name\":\"txListCacheExpiry\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"proofCooldownPeriod\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"systemProofCooldownPeriod\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"realProofSkipSize\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ethDepositGas\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ethDepositMaxFee\",\"type\":\"uint256\"},{\"internalType\":\"uint64\",\"name\":\"minEthDepositsPerBlock\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"maxEthDepositsPerBlock\",\"type\":\"uint64\"},{\"internalType\":\"uint96\",\"name\":\"maxEthDepositAmount\",\"type\":\"uint96\"},{\"internalType\":\"uint96\",\"name\":\"minEthDepositAmount\",\"type\":\"uint96\"},{\"internalType\":\"bool\",\"name\":\"relaySignalRoot\",\"type\":\"bool\"}],\"internalType\":\"structMxcData.Config\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"blockId\",\"type\":\"uint256\"}],\"name\":\"getCrossChainBlockHash\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"blockId\",\"type\":\"uint256\"}],\"name\":\"getCrossChainSignalRoot\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"blockId\",\"type\":\"uint256\"},{\"internalType\":\"bytes32\",\"name\":\"parentHash\",\"type\":\"bytes32\"},{\"internalType\":\"uint32\",\"name\":\"parentGasUsed\",\"type\":\"uint32\"}],\"name\":\"getForkChoice\",\"outputs\":[{\"components\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"signalRoot\",\"type\":\"bytes32\"},{\"internalType\":\"uint64\",\"name\":\"provenAt\",\"type\":\"uint64\"},{\"internalType\":\"address\",\"name\":\"prover\",\"type\":\"address\"},{\"internalType\":\"uint32\",\"name\":\"gasUsed\",\"type\":\"uint32\"}],\"internalType\":\"structMxcData.ForkChoice\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"getMxcTokenBalance\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"proofTime\",\"type\":\"uint64\"}],\"name\":\"getProofReward\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getProposeReward\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getStateVariables\",\"outputs\":[{\"components\":[{\"internalType\":\"uint64\",\"name\":\"blockFee\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"accBlockFees\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"genesisHeight\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"genesisTimestamp\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"numBlocks\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"proofTimeIssued\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"proofTimeTarget\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"lastVerifiedBlockId\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"accProposedAt\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"nextEthDepositToProcess\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"numEthDeposits\",\"type\":\"uint64\"}],\"internalType\":\"structMxcData.StateVariables\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint16\",\"name\":\"id\",\"type\":\"uint16\"}],\"name\":\"getVerifierName\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"_addressManager\",\"type\":\"address\"},{\"internalType\":\"bytes32\",\"name\":\"_genesisBlockHash\",\"type\":\"bytes32\"},{\"internalType\":\"uint64\",\"name\":\"_initBlockFee\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"_initProofTimeTarget\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"_initProofTimeIssued\",\"type\":\"uint64\"},{\"internalType\":\"uint16\",\"name\":\"_adjustmentQuotient\",\"type\":\"uint16\"}],\"name\":\"init\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes\",\"name\":\"input\",\"type\":\"bytes\"},{\"internalType\":\"bytes\",\"name\":\"txList\",\"type\":\"bytes\"}],\"name\":\"proposeBlock\",\"outputs\":[{\"components\":[{\"internalType\":\"uint64\",\"name\":\"id\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"timestamp\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"l1Height\",\"type\":\"uint64\"},{\"internalType\":\"bytes32\",\"name\":\"l1Hash\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"mixHash\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"txListHash\",\"type\":\"bytes32\"},{\"internalType\":\"uint24\",\"name\":\"txListByteStart\",\"type\":\"uint24\"},{\"internalType\":\"uint24\",\"name\":\"txListByteEnd\",\"type\":\"uint24\"},{\"internalType\":\"uint32\",\"name\":\"gasLimit\",\"type\":\"uint32\"},{\"internalType\":\"address\",\"name\":\"beneficiary\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"treasury\",\"type\":\"address\"},{\"components\":[{\"internalType\":\"address\",\"name\":\"recipient\",\"type\":\"address\"},{\"internalType\":\"uint96\",\"name\":\"amount\",\"type\":\"uint96\"},{\"internalType\":\"uint64\",\"name\":\"id\",\"type\":\"uint64\"}],\"internalType\":\"structMxcData.EthDeposit[]\",\"name\":\"depositsProcessed\",\"type\":\"tuple[]\"},{\"internalType\":\"uint256\",\"name\":\"baseFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"blockReward\",\"type\":\"uint256\"}],\"internalType\":\"structMxcData.BlockMetadata\",\"name\":\"meta\",\"type\":\"tuple\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"blockId\",\"type\":\"uint256\"},{\"internalType\":\"bytes\",\"name\":\"input\",\"type\":\"bytes\"}],\"name\":\"proveBlock\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"renounceOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"chainId\",\"type\":\"uint256\"},{\"internalType\":\"bytes32\",\"name\":\"name\",\"type\":\"bytes32\"},{\"internalType\":\"bool\",\"name\":\"allowZeroAddress\",\"type\":\"bool\"}],\"name\":\"resolve\",\"outputs\":[{\"internalType\":\"addresspayable\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"name\",\"type\":\"bytes32\"},{\"internalType\":\"bool\",\"name\":\"allowZeroAddress\",\"type\":\"bool\"}],\"name\":\"resolve\",\"outputs\":[{\"internalType\":\"addresspayable\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"newAddressManager\",\"type\":\"address\"}],\"name\":\"setAddressManager\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"newProofTimeTarget\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"newProofTimeIssued\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"newBlockFee\",\"type\":\"uint64\"},{\"internalType\":\"uint16\",\"name\":\"newAdjustmentQuotient\",\"type\":\"uint16\"}],\"name\":\"setProofParams\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"state\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"totalStakeMxcTokenBalances\",\"type\":\"uint256\"},{\"internalType\":\"uint64\",\"name\":\"genesisHeight\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"genesisTimestamp\",\"type\":\"uint64\"},{\"internalType\":\"uint16\",\"name\":\"adjustmentQuotient\",\"type\":\"uint16\"},{\"internalType\":\"uint48\",\"name\":\"prevBaseFee\",\"type\":\"uint48\"},{\"internalType\":\"uint64\",\"name\":\"proposerElectionTimeoutOffset\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"accProposedAt\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"accBlockFees\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"numBlocks\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"proveMetaReward\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"blockFee\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"proofTimeIssued\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"lastVerifiedBlockId\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"proofTimeTarget\",\"type\":\"uint64\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"maxBlocks\",\"type\":\"uint256\"}],\"name\":\"verifyBlocks\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"withdrawMxcToken\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"stateMutability\":\"payable\",\"type\":\"receive\"}]",
}

// MxcL1ABI is the input ABI used to generate the binding from.
// Deprecated: Use MxcL1MetaData.ABI instead.
var MxcL1ABI = MxcL1MetaData.ABI

// MxcL1 is an auto generated Go binding around an Ethereum contract.
type MxcL1 struct {
	MxcL1Caller     // Read-only binding to the contract
	MxcL1Transactor // Write-only binding to the contract
	MxcL1Filterer   // Log filterer for contract events
}

// MxcL1Caller is an auto generated read-only Go binding around an Ethereum contract.
type MxcL1Caller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MxcL1Transactor is an auto generated write-only Go binding around an Ethereum contract.
type MxcL1Transactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MxcL1Filterer is an auto generated log filtering Go binding around an Ethereum contract events.
type MxcL1Filterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MxcL1Session is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type MxcL1Session struct {
	Contract     *MxcL1            // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// MxcL1CallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type MxcL1CallerSession struct {
	Contract *MxcL1Caller  // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts // Call options to use throughout this session
}

// MxcL1TransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type MxcL1TransactorSession struct {
	Contract     *MxcL1Transactor  // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// MxcL1Raw is an auto generated low-level Go binding around an Ethereum contract.
type MxcL1Raw struct {
	Contract *MxcL1 // Generic contract binding to access the raw methods on
}

// MxcL1CallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type MxcL1CallerRaw struct {
	Contract *MxcL1Caller // Generic read-only contract binding to access the raw methods on
}

// MxcL1TransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type MxcL1TransactorRaw struct {
	Contract *MxcL1Transactor // Generic write-only contract binding to access the raw methods on
}

// NewMxcL1 creates a new instance of MxcL1, bound to a specific deployed contract.
func NewMxcL1(address common.Address, backend bind.ContractBackend) (*MxcL1, error) {
	contract, err := bindMxcL1(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &MxcL1{MxcL1Caller: MxcL1Caller{contract: contract}, MxcL1Transactor: MxcL1Transactor{contract: contract}, MxcL1Filterer: MxcL1Filterer{contract: contract}}, nil
}

// NewMxcL1Caller creates a new read-only instance of MxcL1, bound to a specific deployed contract.
func NewMxcL1Caller(address common.Address, caller bind.ContractCaller) (*MxcL1Caller, error) {
	contract, err := bindMxcL1(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &MxcL1Caller{contract: contract}, nil
}

// NewMxcL1Transactor creates a new write-only instance of MxcL1, bound to a specific deployed contract.
func NewMxcL1Transactor(address common.Address, transactor bind.ContractTransactor) (*MxcL1Transactor, error) {
	contract, err := bindMxcL1(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &MxcL1Transactor{contract: contract}, nil
}

// NewMxcL1Filterer creates a new log filterer instance of MxcL1, bound to a specific deployed contract.
func NewMxcL1Filterer(address common.Address, filterer bind.ContractFilterer) (*MxcL1Filterer, error) {
	contract, err := bindMxcL1(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &MxcL1Filterer{contract: contract}, nil
}

// bindMxcL1 binds a generic wrapper to an already deployed contract.
func bindMxcL1(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := MxcL1MetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_MxcL1 *MxcL1Raw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _MxcL1.Contract.MxcL1Caller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_MxcL1 *MxcL1Raw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MxcL1.Contract.MxcL1Transactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_MxcL1 *MxcL1Raw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _MxcL1.Contract.MxcL1Transactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_MxcL1 *MxcL1CallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _MxcL1.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_MxcL1 *MxcL1TransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MxcL1.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_MxcL1 *MxcL1TransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _MxcL1.Contract.contract.Transact(opts, method, params...)
}

// AddressManager is a free data retrieval call binding the contract method 0x3ab76e9f.
//
// Solidity: function addressManager() view returns(address)
func (_MxcL1 *MxcL1Caller) AddressManager(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "addressManager")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// AddressManager is a free data retrieval call binding the contract method 0x3ab76e9f.
//
// Solidity: function addressManager() view returns(address)
func (_MxcL1 *MxcL1Session) AddressManager() (common.Address, error) {
	return _MxcL1.Contract.AddressManager(&_MxcL1.CallOpts)
}

// AddressManager is a free data retrieval call binding the contract method 0x3ab76e9f.
//
// Solidity: function addressManager() view returns(address)
func (_MxcL1 *MxcL1CallerSession) AddressManager() (common.Address, error) {
	return _MxcL1.Contract.AddressManager(&_MxcL1.CallOpts)
}

// GetBlock is a free data retrieval call binding the contract method 0x04c07569.
//
// Solidity: function getBlock(uint256 blockId) view returns(bytes32 _metaHash, address _proposer, uint64 _proposedAt)
func (_MxcL1 *MxcL1Caller) GetBlock(opts *bind.CallOpts, blockId *big.Int) (struct {
	MetaHash   [32]byte
	Proposer   common.Address
	ProposedAt uint64
}, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getBlock", blockId)

	outstruct := new(struct {
		MetaHash   [32]byte
		Proposer   common.Address
		ProposedAt uint64
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.MetaHash = *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)
	outstruct.Proposer = *abi.ConvertType(out[1], new(common.Address)).(*common.Address)
	outstruct.ProposedAt = *abi.ConvertType(out[2], new(uint64)).(*uint64)

	return *outstruct, err

}

// GetBlock is a free data retrieval call binding the contract method 0x04c07569.
//
// Solidity: function getBlock(uint256 blockId) view returns(bytes32 _metaHash, address _proposer, uint64 _proposedAt)
func (_MxcL1 *MxcL1Session) GetBlock(blockId *big.Int) (struct {
	MetaHash   [32]byte
	Proposer   common.Address
	ProposedAt uint64
}, error) {
	return _MxcL1.Contract.GetBlock(&_MxcL1.CallOpts, blockId)
}

// GetBlock is a free data retrieval call binding the contract method 0x04c07569.
//
// Solidity: function getBlock(uint256 blockId) view returns(bytes32 _metaHash, address _proposer, uint64 _proposedAt)
func (_MxcL1 *MxcL1CallerSession) GetBlock(blockId *big.Int) (struct {
	MetaHash   [32]byte
	Proposer   common.Address
	ProposedAt uint64
}, error) {
	return _MxcL1.Contract.GetBlock(&_MxcL1.CallOpts, blockId)
}

// GetBlockFee is a free data retrieval call binding the contract method 0x7baf0bc7.
//
// Solidity: function getBlockFee() view returns(uint64)
func (_MxcL1 *MxcL1Caller) GetBlockFee(opts *bind.CallOpts) (uint64, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getBlockFee")

	if err != nil {
		return *new(uint64), err
	}

	out0 := *abi.ConvertType(out[0], new(uint64)).(*uint64)

	return out0, err

}

// GetBlockFee is a free data retrieval call binding the contract method 0x7baf0bc7.
//
// Solidity: function getBlockFee() view returns(uint64)
func (_MxcL1 *MxcL1Session) GetBlockFee() (uint64, error) {
	return _MxcL1.Contract.GetBlockFee(&_MxcL1.CallOpts)
}

// GetBlockFee is a free data retrieval call binding the contract method 0x7baf0bc7.
//
// Solidity: function getBlockFee() view returns(uint64)
func (_MxcL1 *MxcL1CallerSession) GetBlockFee() (uint64, error) {
	return _MxcL1.Contract.GetBlockFee(&_MxcL1.CallOpts)
}

// GetConfig is a free data retrieval call binding the contract method 0xc3f909d4.
//
// Solidity: function getConfig() pure returns((uint256,uint256,uint256,uint256,uint64,uint64,uint64,uint256,uint256,uint256,uint256,uint256,uint256,uint64,uint64,uint96,uint96,bool))
func (_MxcL1 *MxcL1Caller) GetConfig(opts *bind.CallOpts) (MxcDataConfig, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getConfig")

	if err != nil {
		return *new(MxcDataConfig), err
	}

	out0 := *abi.ConvertType(out[0], new(MxcDataConfig)).(*MxcDataConfig)

	return out0, err

}

// GetConfig is a free data retrieval call binding the contract method 0xc3f909d4.
//
// Solidity: function getConfig() pure returns((uint256,uint256,uint256,uint256,uint64,uint64,uint64,uint256,uint256,uint256,uint256,uint256,uint256,uint64,uint64,uint96,uint96,bool))
func (_MxcL1 *MxcL1Session) GetConfig() (MxcDataConfig, error) {
	return _MxcL1.Contract.GetConfig(&_MxcL1.CallOpts)
}

// GetConfig is a free data retrieval call binding the contract method 0xc3f909d4.
//
// Solidity: function getConfig() pure returns((uint256,uint256,uint256,uint256,uint64,uint64,uint64,uint256,uint256,uint256,uint256,uint256,uint256,uint64,uint64,uint96,uint96,bool))
func (_MxcL1 *MxcL1CallerSession) GetConfig() (MxcDataConfig, error) {
	return _MxcL1.Contract.GetConfig(&_MxcL1.CallOpts)
}

// GetCrossChainBlockHash is a free data retrieval call binding the contract method 0xbacb386d.
//
// Solidity: function getCrossChainBlockHash(uint256 blockId) view returns(bytes32)
func (_MxcL1 *MxcL1Caller) GetCrossChainBlockHash(opts *bind.CallOpts, blockId *big.Int) ([32]byte, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getCrossChainBlockHash", blockId)

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// GetCrossChainBlockHash is a free data retrieval call binding the contract method 0xbacb386d.
//
// Solidity: function getCrossChainBlockHash(uint256 blockId) view returns(bytes32)
func (_MxcL1 *MxcL1Session) GetCrossChainBlockHash(blockId *big.Int) ([32]byte, error) {
	return _MxcL1.Contract.GetCrossChainBlockHash(&_MxcL1.CallOpts, blockId)
}

// GetCrossChainBlockHash is a free data retrieval call binding the contract method 0xbacb386d.
//
// Solidity: function getCrossChainBlockHash(uint256 blockId) view returns(bytes32)
func (_MxcL1 *MxcL1CallerSession) GetCrossChainBlockHash(blockId *big.Int) ([32]byte, error) {
	return _MxcL1.Contract.GetCrossChainBlockHash(&_MxcL1.CallOpts, blockId)
}

// GetCrossChainSignalRoot is a free data retrieval call binding the contract method 0xb8914ce4.
//
// Solidity: function getCrossChainSignalRoot(uint256 blockId) view returns(bytes32)
func (_MxcL1 *MxcL1Caller) GetCrossChainSignalRoot(opts *bind.CallOpts, blockId *big.Int) ([32]byte, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getCrossChainSignalRoot", blockId)

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// GetCrossChainSignalRoot is a free data retrieval call binding the contract method 0xb8914ce4.
//
// Solidity: function getCrossChainSignalRoot(uint256 blockId) view returns(bytes32)
func (_MxcL1 *MxcL1Session) GetCrossChainSignalRoot(blockId *big.Int) ([32]byte, error) {
	return _MxcL1.Contract.GetCrossChainSignalRoot(&_MxcL1.CallOpts, blockId)
}

// GetCrossChainSignalRoot is a free data retrieval call binding the contract method 0xb8914ce4.
//
// Solidity: function getCrossChainSignalRoot(uint256 blockId) view returns(bytes32)
func (_MxcL1 *MxcL1CallerSession) GetCrossChainSignalRoot(blockId *big.Int) ([32]byte, error) {
	return _MxcL1.Contract.GetCrossChainSignalRoot(&_MxcL1.CallOpts, blockId)
}

// GetForkChoice is a free data retrieval call binding the contract method 0x7163e0ed.
//
// Solidity: function getForkChoice(uint256 blockId, bytes32 parentHash, uint32 parentGasUsed) view returns((bytes32,bytes32,bytes32,uint64,address,uint32))
func (_MxcL1 *MxcL1Caller) GetForkChoice(opts *bind.CallOpts, blockId *big.Int, parentHash [32]byte, parentGasUsed uint32) (MxcDataForkChoice, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getForkChoice", blockId, parentHash, parentGasUsed)

	if err != nil {
		return *new(MxcDataForkChoice), err
	}

	out0 := *abi.ConvertType(out[0], new(MxcDataForkChoice)).(*MxcDataForkChoice)

	return out0, err

}

// GetForkChoice is a free data retrieval call binding the contract method 0x7163e0ed.
//
// Solidity: function getForkChoice(uint256 blockId, bytes32 parentHash, uint32 parentGasUsed) view returns((bytes32,bytes32,bytes32,uint64,address,uint32))
func (_MxcL1 *MxcL1Session) GetForkChoice(blockId *big.Int, parentHash [32]byte, parentGasUsed uint32) (MxcDataForkChoice, error) {
	return _MxcL1.Contract.GetForkChoice(&_MxcL1.CallOpts, blockId, parentHash, parentGasUsed)
}

// GetForkChoice is a free data retrieval call binding the contract method 0x7163e0ed.
//
// Solidity: function getForkChoice(uint256 blockId, bytes32 parentHash, uint32 parentGasUsed) view returns((bytes32,bytes32,bytes32,uint64,address,uint32))
func (_MxcL1 *MxcL1CallerSession) GetForkChoice(blockId *big.Int, parentHash [32]byte, parentGasUsed uint32) (MxcDataForkChoice, error) {
	return _MxcL1.Contract.GetForkChoice(&_MxcL1.CallOpts, blockId, parentHash, parentGasUsed)
}

// GetMxcTokenBalance is a free data retrieval call binding the contract method 0xc21f0775.
//
// Solidity: function getMxcTokenBalance(address addr) view returns(uint256)
func (_MxcL1 *MxcL1Caller) GetMxcTokenBalance(opts *bind.CallOpts, addr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getMxcTokenBalance", addr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetMxcTokenBalance is a free data retrieval call binding the contract method 0xc21f0775.
//
// Solidity: function getMxcTokenBalance(address addr) view returns(uint256)
func (_MxcL1 *MxcL1Session) GetMxcTokenBalance(addr common.Address) (*big.Int, error) {
	return _MxcL1.Contract.GetMxcTokenBalance(&_MxcL1.CallOpts, addr)
}

// GetMxcTokenBalance is a free data retrieval call binding the contract method 0xc21f0775.
//
// Solidity: function getMxcTokenBalance(address addr) view returns(uint256)
func (_MxcL1 *MxcL1CallerSession) GetMxcTokenBalance(addr common.Address) (*big.Int, error) {
	return _MxcL1.Contract.GetMxcTokenBalance(&_MxcL1.CallOpts, addr)
}

// GetProofReward is a free data retrieval call binding the contract method 0x55f7259e.
//
// Solidity: function getProofReward(uint64 proofTime) view returns(uint256)
func (_MxcL1 *MxcL1Caller) GetProofReward(opts *bind.CallOpts, proofTime uint64) (*big.Int, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getProofReward", proofTime)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetProofReward is a free data retrieval call binding the contract method 0x55f7259e.
//
// Solidity: function getProofReward(uint64 proofTime) view returns(uint256)
func (_MxcL1 *MxcL1Session) GetProofReward(proofTime uint64) (*big.Int, error) {
	return _MxcL1.Contract.GetProofReward(&_MxcL1.CallOpts, proofTime)
}

// GetProofReward is a free data retrieval call binding the contract method 0x55f7259e.
//
// Solidity: function getProofReward(uint64 proofTime) view returns(uint256)
func (_MxcL1 *MxcL1CallerSession) GetProofReward(proofTime uint64) (*big.Int, error) {
	return _MxcL1.Contract.GetProofReward(&_MxcL1.CallOpts, proofTime)
}

// GetProposeReward is a free data retrieval call binding the contract method 0xe527c8b7.
//
// Solidity: function getProposeReward() view returns(uint256)
func (_MxcL1 *MxcL1Caller) GetProposeReward(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getProposeReward")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetProposeReward is a free data retrieval call binding the contract method 0xe527c8b7.
//
// Solidity: function getProposeReward() view returns(uint256)
func (_MxcL1 *MxcL1Session) GetProposeReward() (*big.Int, error) {
	return _MxcL1.Contract.GetProposeReward(&_MxcL1.CallOpts)
}

// GetProposeReward is a free data retrieval call binding the contract method 0xe527c8b7.
//
// Solidity: function getProposeReward() view returns(uint256)
func (_MxcL1 *MxcL1CallerSession) GetProposeReward() (*big.Int, error) {
	return _MxcL1.Contract.GetProposeReward(&_MxcL1.CallOpts)
}

// GetStateVariables is a free data retrieval call binding the contract method 0xdde89cf5.
//
// Solidity: function getStateVariables() view returns((uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64))
func (_MxcL1 *MxcL1Caller) GetStateVariables(opts *bind.CallOpts) (MxcDataStateVariables, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getStateVariables")

	if err != nil {
		return *new(MxcDataStateVariables), err
	}

	out0 := *abi.ConvertType(out[0], new(MxcDataStateVariables)).(*MxcDataStateVariables)

	return out0, err

}

// GetStateVariables is a free data retrieval call binding the contract method 0xdde89cf5.
//
// Solidity: function getStateVariables() view returns((uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64))
func (_MxcL1 *MxcL1Session) GetStateVariables() (MxcDataStateVariables, error) {
	return _MxcL1.Contract.GetStateVariables(&_MxcL1.CallOpts)
}

// GetStateVariables is a free data retrieval call binding the contract method 0xdde89cf5.
//
// Solidity: function getStateVariables() view returns((uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64,uint64))
func (_MxcL1 *MxcL1CallerSession) GetStateVariables() (MxcDataStateVariables, error) {
	return _MxcL1.Contract.GetStateVariables(&_MxcL1.CallOpts)
}

// GetVerifierName is a free data retrieval call binding the contract method 0x0372303d.
//
// Solidity: function getVerifierName(uint16 id) pure returns(bytes32)
func (_MxcL1 *MxcL1Caller) GetVerifierName(opts *bind.CallOpts, id uint16) ([32]byte, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "getVerifierName", id)

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// GetVerifierName is a free data retrieval call binding the contract method 0x0372303d.
//
// Solidity: function getVerifierName(uint16 id) pure returns(bytes32)
func (_MxcL1 *MxcL1Session) GetVerifierName(id uint16) ([32]byte, error) {
	return _MxcL1.Contract.GetVerifierName(&_MxcL1.CallOpts, id)
}

// GetVerifierName is a free data retrieval call binding the contract method 0x0372303d.
//
// Solidity: function getVerifierName(uint16 id) pure returns(bytes32)
func (_MxcL1 *MxcL1CallerSession) GetVerifierName(id uint16) ([32]byte, error) {
	return _MxcL1.Contract.GetVerifierName(&_MxcL1.CallOpts, id)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_MxcL1 *MxcL1Caller) Owner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_MxcL1 *MxcL1Session) Owner() (common.Address, error) {
	return _MxcL1.Contract.Owner(&_MxcL1.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_MxcL1 *MxcL1CallerSession) Owner() (common.Address, error) {
	return _MxcL1.Contract.Owner(&_MxcL1.CallOpts)
}

// Resolve is a free data retrieval call binding the contract method 0x6c6563f6.
//
// Solidity: function resolve(uint256 chainId, bytes32 name, bool allowZeroAddress) view returns(address)
func (_MxcL1 *MxcL1Caller) Resolve(opts *bind.CallOpts, chainId *big.Int, name [32]byte, allowZeroAddress bool) (common.Address, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "resolve", chainId, name, allowZeroAddress)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Resolve is a free data retrieval call binding the contract method 0x6c6563f6.
//
// Solidity: function resolve(uint256 chainId, bytes32 name, bool allowZeroAddress) view returns(address)
func (_MxcL1 *MxcL1Session) Resolve(chainId *big.Int, name [32]byte, allowZeroAddress bool) (common.Address, error) {
	return _MxcL1.Contract.Resolve(&_MxcL1.CallOpts, chainId, name, allowZeroAddress)
}

// Resolve is a free data retrieval call binding the contract method 0x6c6563f6.
//
// Solidity: function resolve(uint256 chainId, bytes32 name, bool allowZeroAddress) view returns(address)
func (_MxcL1 *MxcL1CallerSession) Resolve(chainId *big.Int, name [32]byte, allowZeroAddress bool) (common.Address, error) {
	return _MxcL1.Contract.Resolve(&_MxcL1.CallOpts, chainId, name, allowZeroAddress)
}

// Resolve0 is a free data retrieval call binding the contract method 0xa86f9d9e.
//
// Solidity: function resolve(bytes32 name, bool allowZeroAddress) view returns(address)
func (_MxcL1 *MxcL1Caller) Resolve0(opts *bind.CallOpts, name [32]byte, allowZeroAddress bool) (common.Address, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "resolve0", name, allowZeroAddress)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Resolve0 is a free data retrieval call binding the contract method 0xa86f9d9e.
//
// Solidity: function resolve(bytes32 name, bool allowZeroAddress) view returns(address)
func (_MxcL1 *MxcL1Session) Resolve0(name [32]byte, allowZeroAddress bool) (common.Address, error) {
	return _MxcL1.Contract.Resolve0(&_MxcL1.CallOpts, name, allowZeroAddress)
}

// Resolve0 is a free data retrieval call binding the contract method 0xa86f9d9e.
//
// Solidity: function resolve(bytes32 name, bool allowZeroAddress) view returns(address)
func (_MxcL1 *MxcL1CallerSession) Resolve0(name [32]byte, allowZeroAddress bool) (common.Address, error) {
	return _MxcL1.Contract.Resolve0(&_MxcL1.CallOpts, name, allowZeroAddress)
}

// State is a free data retrieval call binding the contract method 0xc19d93fb.
//
// Solidity: function state() view returns(uint256 totalStakeMxcTokenBalances, uint64 genesisHeight, uint64 genesisTimestamp, uint16 adjustmentQuotient, uint48 prevBaseFee, uint64 proposerElectionTimeoutOffset, uint64 accProposedAt, uint64 accBlockFees, uint64 numBlocks, uint64 proveMetaReward, uint64 blockFee, uint64 proofTimeIssued, uint64 lastVerifiedBlockId, uint64 proofTimeTarget)
func (_MxcL1 *MxcL1Caller) State(opts *bind.CallOpts) (struct {
	TotalStakeMxcTokenBalances    *big.Int
	GenesisHeight                 uint64
	GenesisTimestamp              uint64
	AdjustmentQuotient            uint16
	PrevBaseFee                   *big.Int
	ProposerElectionTimeoutOffset uint64
	AccProposedAt                 uint64
	AccBlockFees                  uint64
	NumBlocks                     uint64
	ProveMetaReward               uint64
	BlockFee                      uint64
	ProofTimeIssued               uint64
	LastVerifiedBlockId           uint64
	ProofTimeTarget               uint64
}, error) {
	var out []interface{}
	err := _MxcL1.contract.Call(opts, &out, "state")

	outstruct := new(struct {
		TotalStakeMxcTokenBalances    *big.Int
		GenesisHeight                 uint64
		GenesisTimestamp              uint64
		AdjustmentQuotient            uint16
		PrevBaseFee                   *big.Int
		ProposerElectionTimeoutOffset uint64
		AccProposedAt                 uint64
		AccBlockFees                  uint64
		NumBlocks                     uint64
		ProveMetaReward               uint64
		BlockFee                      uint64
		ProofTimeIssued               uint64
		LastVerifiedBlockId           uint64
		ProofTimeTarget               uint64
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.TotalStakeMxcTokenBalances = *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	outstruct.GenesisHeight = *abi.ConvertType(out[1], new(uint64)).(*uint64)
	outstruct.GenesisTimestamp = *abi.ConvertType(out[2], new(uint64)).(*uint64)
	outstruct.AdjustmentQuotient = *abi.ConvertType(out[3], new(uint16)).(*uint16)
	outstruct.PrevBaseFee = *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)
	outstruct.ProposerElectionTimeoutOffset = *abi.ConvertType(out[5], new(uint64)).(*uint64)
	outstruct.AccProposedAt = *abi.ConvertType(out[6], new(uint64)).(*uint64)
	outstruct.AccBlockFees = *abi.ConvertType(out[7], new(uint64)).(*uint64)
	outstruct.NumBlocks = *abi.ConvertType(out[8], new(uint64)).(*uint64)
	outstruct.ProveMetaReward = *abi.ConvertType(out[9], new(uint64)).(*uint64)
	outstruct.BlockFee = *abi.ConvertType(out[10], new(uint64)).(*uint64)
	outstruct.ProofTimeIssued = *abi.ConvertType(out[11], new(uint64)).(*uint64)
	outstruct.LastVerifiedBlockId = *abi.ConvertType(out[12], new(uint64)).(*uint64)
	outstruct.ProofTimeTarget = *abi.ConvertType(out[13], new(uint64)).(*uint64)

	return *outstruct, err

}

// State is a free data retrieval call binding the contract method 0xc19d93fb.
//
// Solidity: function state() view returns(uint256 totalStakeMxcTokenBalances, uint64 genesisHeight, uint64 genesisTimestamp, uint16 adjustmentQuotient, uint48 prevBaseFee, uint64 proposerElectionTimeoutOffset, uint64 accProposedAt, uint64 accBlockFees, uint64 numBlocks, uint64 proveMetaReward, uint64 blockFee, uint64 proofTimeIssued, uint64 lastVerifiedBlockId, uint64 proofTimeTarget)
func (_MxcL1 *MxcL1Session) State() (struct {
	TotalStakeMxcTokenBalances    *big.Int
	GenesisHeight                 uint64
	GenesisTimestamp              uint64
	AdjustmentQuotient            uint16
	PrevBaseFee                   *big.Int
	ProposerElectionTimeoutOffset uint64
	AccProposedAt                 uint64
	AccBlockFees                  uint64
	NumBlocks                     uint64
	ProveMetaReward               uint64
	BlockFee                      uint64
	ProofTimeIssued               uint64
	LastVerifiedBlockId           uint64
	ProofTimeTarget               uint64
}, error) {
	return _MxcL1.Contract.State(&_MxcL1.CallOpts)
}

// State is a free data retrieval call binding the contract method 0xc19d93fb.
//
// Solidity: function state() view returns(uint256 totalStakeMxcTokenBalances, uint64 genesisHeight, uint64 genesisTimestamp, uint16 adjustmentQuotient, uint48 prevBaseFee, uint64 proposerElectionTimeoutOffset, uint64 accProposedAt, uint64 accBlockFees, uint64 numBlocks, uint64 proveMetaReward, uint64 blockFee, uint64 proofTimeIssued, uint64 lastVerifiedBlockId, uint64 proofTimeTarget)
func (_MxcL1 *MxcL1CallerSession) State() (struct {
	TotalStakeMxcTokenBalances    *big.Int
	GenesisHeight                 uint64
	GenesisTimestamp              uint64
	AdjustmentQuotient            uint16
	PrevBaseFee                   *big.Int
	ProposerElectionTimeoutOffset uint64
	AccProposedAt                 uint64
	AccBlockFees                  uint64
	NumBlocks                     uint64
	ProveMetaReward               uint64
	BlockFee                      uint64
	ProofTimeIssued               uint64
	LastVerifiedBlockId           uint64
	ProofTimeTarget               uint64
}, error) {
	return _MxcL1.Contract.State(&_MxcL1.CallOpts)
}

// DepositEtherToL2 is a paid mutator transaction binding the contract method 0xa22f7670.
//
// Solidity: function depositEtherToL2() payable returns()
func (_MxcL1 *MxcL1Transactor) DepositEtherToL2(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "depositEtherToL2")
}

// DepositEtherToL2 is a paid mutator transaction binding the contract method 0xa22f7670.
//
// Solidity: function depositEtherToL2() payable returns()
func (_MxcL1 *MxcL1Session) DepositEtherToL2() (*types.Transaction, error) {
	return _MxcL1.Contract.DepositEtherToL2(&_MxcL1.TransactOpts)
}

// DepositEtherToL2 is a paid mutator transaction binding the contract method 0xa22f7670.
//
// Solidity: function depositEtherToL2() payable returns()
func (_MxcL1 *MxcL1TransactorSession) DepositEtherToL2() (*types.Transaction, error) {
	return _MxcL1.Contract.DepositEtherToL2(&_MxcL1.TransactOpts)
}

// DepositMxcToken is a paid mutator transaction binding the contract method 0x5c9c0a14.
//
// Solidity: function depositMxcToken(uint256 amount) returns()
func (_MxcL1 *MxcL1Transactor) DepositMxcToken(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "depositMxcToken", amount)
}

// DepositMxcToken is a paid mutator transaction binding the contract method 0x5c9c0a14.
//
// Solidity: function depositMxcToken(uint256 amount) returns()
func (_MxcL1 *MxcL1Session) DepositMxcToken(amount *big.Int) (*types.Transaction, error) {
	return _MxcL1.Contract.DepositMxcToken(&_MxcL1.TransactOpts, amount)
}

// DepositMxcToken is a paid mutator transaction binding the contract method 0x5c9c0a14.
//
// Solidity: function depositMxcToken(uint256 amount) returns()
func (_MxcL1 *MxcL1TransactorSession) DepositMxcToken(amount *big.Int) (*types.Transaction, error) {
	return _MxcL1.Contract.DepositMxcToken(&_MxcL1.TransactOpts, amount)
}

// Init is a paid mutator transaction binding the contract method 0xc7a64b19.
//
// Solidity: function init(address _addressManager, bytes32 _genesisBlockHash, uint64 _initBlockFee, uint64 _initProofTimeTarget, uint64 _initProofTimeIssued, uint16 _adjustmentQuotient) returns()
func (_MxcL1 *MxcL1Transactor) Init(opts *bind.TransactOpts, _addressManager common.Address, _genesisBlockHash [32]byte, _initBlockFee uint64, _initProofTimeTarget uint64, _initProofTimeIssued uint64, _adjustmentQuotient uint16) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "init", _addressManager, _genesisBlockHash, _initBlockFee, _initProofTimeTarget, _initProofTimeIssued, _adjustmentQuotient)
}

// Init is a paid mutator transaction binding the contract method 0xc7a64b19.
//
// Solidity: function init(address _addressManager, bytes32 _genesisBlockHash, uint64 _initBlockFee, uint64 _initProofTimeTarget, uint64 _initProofTimeIssued, uint16 _adjustmentQuotient) returns()
func (_MxcL1 *MxcL1Session) Init(_addressManager common.Address, _genesisBlockHash [32]byte, _initBlockFee uint64, _initProofTimeTarget uint64, _initProofTimeIssued uint64, _adjustmentQuotient uint16) (*types.Transaction, error) {
	return _MxcL1.Contract.Init(&_MxcL1.TransactOpts, _addressManager, _genesisBlockHash, _initBlockFee, _initProofTimeTarget, _initProofTimeIssued, _adjustmentQuotient)
}

// Init is a paid mutator transaction binding the contract method 0xc7a64b19.
//
// Solidity: function init(address _addressManager, bytes32 _genesisBlockHash, uint64 _initBlockFee, uint64 _initProofTimeTarget, uint64 _initProofTimeIssued, uint16 _adjustmentQuotient) returns()
func (_MxcL1 *MxcL1TransactorSession) Init(_addressManager common.Address, _genesisBlockHash [32]byte, _initBlockFee uint64, _initProofTimeTarget uint64, _initProofTimeIssued uint64, _adjustmentQuotient uint16) (*types.Transaction, error) {
	return _MxcL1.Contract.Init(&_MxcL1.TransactOpts, _addressManager, _genesisBlockHash, _initBlockFee, _initProofTimeTarget, _initProofTimeIssued, _adjustmentQuotient)
}

// ProposeBlock is a paid mutator transaction binding the contract method 0xef16e845.
//
// Solidity: function proposeBlock(bytes input, bytes txList) returns((uint64,uint64,uint64,bytes32,bytes32,bytes32,uint24,uint24,uint32,address,address,(address,uint96,uint64)[],uint256,uint256) meta)
func (_MxcL1 *MxcL1Transactor) ProposeBlock(opts *bind.TransactOpts, input []byte, txList []byte) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "proposeBlock", input, txList)
}

// ProposeBlock is a paid mutator transaction binding the contract method 0xef16e845.
//
// Solidity: function proposeBlock(bytes input, bytes txList) returns((uint64,uint64,uint64,bytes32,bytes32,bytes32,uint24,uint24,uint32,address,address,(address,uint96,uint64)[],uint256,uint256) meta)
func (_MxcL1 *MxcL1Session) ProposeBlock(input []byte, txList []byte) (*types.Transaction, error) {
	return _MxcL1.Contract.ProposeBlock(&_MxcL1.TransactOpts, input, txList)
}

// ProposeBlock is a paid mutator transaction binding the contract method 0xef16e845.
//
// Solidity: function proposeBlock(bytes input, bytes txList) returns((uint64,uint64,uint64,bytes32,bytes32,bytes32,uint24,uint24,uint32,address,address,(address,uint96,uint64)[],uint256,uint256) meta)
func (_MxcL1 *MxcL1TransactorSession) ProposeBlock(input []byte, txList []byte) (*types.Transaction, error) {
	return _MxcL1.Contract.ProposeBlock(&_MxcL1.TransactOpts, input, txList)
}

// ProveBlock is a paid mutator transaction binding the contract method 0xf3840f60.
//
// Solidity: function proveBlock(uint256 blockId, bytes input) returns()
func (_MxcL1 *MxcL1Transactor) ProveBlock(opts *bind.TransactOpts, blockId *big.Int, input []byte) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "proveBlock", blockId, input)
}

// ProveBlock is a paid mutator transaction binding the contract method 0xf3840f60.
//
// Solidity: function proveBlock(uint256 blockId, bytes input) returns()
func (_MxcL1 *MxcL1Session) ProveBlock(blockId *big.Int, input []byte) (*types.Transaction, error) {
	return _MxcL1.Contract.ProveBlock(&_MxcL1.TransactOpts, blockId, input)
}

// ProveBlock is a paid mutator transaction binding the contract method 0xf3840f60.
//
// Solidity: function proveBlock(uint256 blockId, bytes input) returns()
func (_MxcL1 *MxcL1TransactorSession) ProveBlock(blockId *big.Int, input []byte) (*types.Transaction, error) {
	return _MxcL1.Contract.ProveBlock(&_MxcL1.TransactOpts, blockId, input)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() returns()
func (_MxcL1 *MxcL1Transactor) RenounceOwnership(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "renounceOwnership")
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() returns()
func (_MxcL1 *MxcL1Session) RenounceOwnership() (*types.Transaction, error) {
	return _MxcL1.Contract.RenounceOwnership(&_MxcL1.TransactOpts)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() returns()
func (_MxcL1 *MxcL1TransactorSession) RenounceOwnership() (*types.Transaction, error) {
	return _MxcL1.Contract.RenounceOwnership(&_MxcL1.TransactOpts)
}

// SetAddressManager is a paid mutator transaction binding the contract method 0x0652b57a.
//
// Solidity: function setAddressManager(address newAddressManager) returns()
func (_MxcL1 *MxcL1Transactor) SetAddressManager(opts *bind.TransactOpts, newAddressManager common.Address) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "setAddressManager", newAddressManager)
}

// SetAddressManager is a paid mutator transaction binding the contract method 0x0652b57a.
//
// Solidity: function setAddressManager(address newAddressManager) returns()
func (_MxcL1 *MxcL1Session) SetAddressManager(newAddressManager common.Address) (*types.Transaction, error) {
	return _MxcL1.Contract.SetAddressManager(&_MxcL1.TransactOpts, newAddressManager)
}

// SetAddressManager is a paid mutator transaction binding the contract method 0x0652b57a.
//
// Solidity: function setAddressManager(address newAddressManager) returns()
func (_MxcL1 *MxcL1TransactorSession) SetAddressManager(newAddressManager common.Address) (*types.Transaction, error) {
	return _MxcL1.Contract.SetAddressManager(&_MxcL1.TransactOpts, newAddressManager)
}

// SetProofParams is a paid mutator transaction binding the contract method 0xae46a347.
//
// Solidity: function setProofParams(uint64 newProofTimeTarget, uint64 newProofTimeIssued, uint64 newBlockFee, uint16 newAdjustmentQuotient) returns()
func (_MxcL1 *MxcL1Transactor) SetProofParams(opts *bind.TransactOpts, newProofTimeTarget uint64, newProofTimeIssued uint64, newBlockFee uint64, newAdjustmentQuotient uint16) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "setProofParams", newProofTimeTarget, newProofTimeIssued, newBlockFee, newAdjustmentQuotient)
}

// SetProofParams is a paid mutator transaction binding the contract method 0xae46a347.
//
// Solidity: function setProofParams(uint64 newProofTimeTarget, uint64 newProofTimeIssued, uint64 newBlockFee, uint16 newAdjustmentQuotient) returns()
func (_MxcL1 *MxcL1Session) SetProofParams(newProofTimeTarget uint64, newProofTimeIssued uint64, newBlockFee uint64, newAdjustmentQuotient uint16) (*types.Transaction, error) {
	return _MxcL1.Contract.SetProofParams(&_MxcL1.TransactOpts, newProofTimeTarget, newProofTimeIssued, newBlockFee, newAdjustmentQuotient)
}

// SetProofParams is a paid mutator transaction binding the contract method 0xae46a347.
//
// Solidity: function setProofParams(uint64 newProofTimeTarget, uint64 newProofTimeIssued, uint64 newBlockFee, uint16 newAdjustmentQuotient) returns()
func (_MxcL1 *MxcL1TransactorSession) SetProofParams(newProofTimeTarget uint64, newProofTimeIssued uint64, newBlockFee uint64, newAdjustmentQuotient uint16) (*types.Transaction, error) {
	return _MxcL1.Contract.SetProofParams(&_MxcL1.TransactOpts, newProofTimeTarget, newProofTimeIssued, newBlockFee, newAdjustmentQuotient)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) returns()
func (_MxcL1 *MxcL1Transactor) TransferOwnership(opts *bind.TransactOpts, newOwner common.Address) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "transferOwnership", newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) returns()
func (_MxcL1 *MxcL1Session) TransferOwnership(newOwner common.Address) (*types.Transaction, error) {
	return _MxcL1.Contract.TransferOwnership(&_MxcL1.TransactOpts, newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) returns()
func (_MxcL1 *MxcL1TransactorSession) TransferOwnership(newOwner common.Address) (*types.Transaction, error) {
	return _MxcL1.Contract.TransferOwnership(&_MxcL1.TransactOpts, newOwner)
}

// VerifyBlocks is a paid mutator transaction binding the contract method 0x2fb5ae0a.
//
// Solidity: function verifyBlocks(uint256 maxBlocks) returns()
func (_MxcL1 *MxcL1Transactor) VerifyBlocks(opts *bind.TransactOpts, maxBlocks *big.Int) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "verifyBlocks", maxBlocks)
}

// VerifyBlocks is a paid mutator transaction binding the contract method 0x2fb5ae0a.
//
// Solidity: function verifyBlocks(uint256 maxBlocks) returns()
func (_MxcL1 *MxcL1Session) VerifyBlocks(maxBlocks *big.Int) (*types.Transaction, error) {
	return _MxcL1.Contract.VerifyBlocks(&_MxcL1.TransactOpts, maxBlocks)
}

// VerifyBlocks is a paid mutator transaction binding the contract method 0x2fb5ae0a.
//
// Solidity: function verifyBlocks(uint256 maxBlocks) returns()
func (_MxcL1 *MxcL1TransactorSession) VerifyBlocks(maxBlocks *big.Int) (*types.Transaction, error) {
	return _MxcL1.Contract.VerifyBlocks(&_MxcL1.TransactOpts, maxBlocks)
}

// WithdrawMxcToken is a paid mutator transaction binding the contract method 0x51e15268.
//
// Solidity: function withdrawMxcToken(uint256 amount) returns()
func (_MxcL1 *MxcL1Transactor) WithdrawMxcToken(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _MxcL1.contract.Transact(opts, "withdrawMxcToken", amount)
}

// WithdrawMxcToken is a paid mutator transaction binding the contract method 0x51e15268.
//
// Solidity: function withdrawMxcToken(uint256 amount) returns()
func (_MxcL1 *MxcL1Session) WithdrawMxcToken(amount *big.Int) (*types.Transaction, error) {
	return _MxcL1.Contract.WithdrawMxcToken(&_MxcL1.TransactOpts, amount)
}

// WithdrawMxcToken is a paid mutator transaction binding the contract method 0x51e15268.
//
// Solidity: function withdrawMxcToken(uint256 amount) returns()
func (_MxcL1 *MxcL1TransactorSession) WithdrawMxcToken(amount *big.Int) (*types.Transaction, error) {
	return _MxcL1.Contract.WithdrawMxcToken(&_MxcL1.TransactOpts, amount)
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_MxcL1 *MxcL1Transactor) Receive(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MxcL1.contract.RawTransact(opts, nil) // calldata is disallowed for receive function
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_MxcL1 *MxcL1Session) Receive() (*types.Transaction, error) {
	return _MxcL1.Contract.Receive(&_MxcL1.TransactOpts)
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_MxcL1 *MxcL1TransactorSession) Receive() (*types.Transaction, error) {
	return _MxcL1.Contract.Receive(&_MxcL1.TransactOpts)
}

// MxcL1AddressManagerChangedIterator is returned from FilterAddressManagerChanged and is used to iterate over the raw logs and unpacked data for AddressManagerChanged events raised by the MxcL1 contract.
type MxcL1AddressManagerChangedIterator struct {
	Event *MxcL1AddressManagerChanged // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1AddressManagerChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1AddressManagerChanged)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1AddressManagerChanged)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1AddressManagerChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1AddressManagerChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1AddressManagerChanged represents a AddressManagerChanged event raised by the MxcL1 contract.
type MxcL1AddressManagerChanged struct {
	AddressManager common.Address
	Raw            types.Log // Blockchain specific contextual infos
}

// FilterAddressManagerChanged is a free log retrieval operation binding the contract event 0x399ded90cb5ed8d89ef7e76ff4af65c373f06d3bf5d7eef55f4228e7b702a18b.
//
// Solidity: event AddressManagerChanged(address addressManager)
func (_MxcL1 *MxcL1Filterer) FilterAddressManagerChanged(opts *bind.FilterOpts) (*MxcL1AddressManagerChangedIterator, error) {

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "AddressManagerChanged")
	if err != nil {
		return nil, err
	}
	return &MxcL1AddressManagerChangedIterator{contract: _MxcL1.contract, event: "AddressManagerChanged", logs: logs, sub: sub}, nil
}

// WatchAddressManagerChanged is a free log subscription operation binding the contract event 0x399ded90cb5ed8d89ef7e76ff4af65c373f06d3bf5d7eef55f4228e7b702a18b.
//
// Solidity: event AddressManagerChanged(address addressManager)
func (_MxcL1 *MxcL1Filterer) WatchAddressManagerChanged(opts *bind.WatchOpts, sink chan<- *MxcL1AddressManagerChanged) (event.Subscription, error) {

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "AddressManagerChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1AddressManagerChanged)
				if err := _MxcL1.contract.UnpackLog(event, "AddressManagerChanged", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseAddressManagerChanged is a log parse operation binding the contract event 0x399ded90cb5ed8d89ef7e76ff4af65c373f06d3bf5d7eef55f4228e7b702a18b.
//
// Solidity: event AddressManagerChanged(address addressManager)
func (_MxcL1 *MxcL1Filterer) ParseAddressManagerChanged(log types.Log) (*MxcL1AddressManagerChanged, error) {
	event := new(MxcL1AddressManagerChanged)
	if err := _MxcL1.contract.UnpackLog(event, "AddressManagerChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1BlockProposeRewardIterator is returned from FilterBlockProposeReward and is used to iterate over the raw logs and unpacked data for BlockProposeReward events raised by the MxcL1 contract.
type MxcL1BlockProposeRewardIterator struct {
	Event *MxcL1BlockProposeReward // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1BlockProposeRewardIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1BlockProposeReward)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1BlockProposeReward)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1BlockProposeRewardIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1BlockProposeRewardIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1BlockProposeReward represents a BlockProposeReward event raised by the MxcL1 contract.
type MxcL1BlockProposeReward struct {
	Id       *big.Int
	Proposer common.Address
	Reward   *big.Int
	Raw      types.Log // Blockchain specific contextual infos
}

// FilterBlockProposeReward is a free log retrieval operation binding the contract event 0x6c37877020064aabb3c00d8dff4cf6b32ec9dfc400d86b943af79c46492ca791.
//
// Solidity: event BlockProposeReward(uint256 indexed id, address proposer, uint256 reward)
func (_MxcL1 *MxcL1Filterer) FilterBlockProposeReward(opts *bind.FilterOpts, id []*big.Int) (*MxcL1BlockProposeRewardIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "BlockProposeReward", idRule)
	if err != nil {
		return nil, err
	}
	return &MxcL1BlockProposeRewardIterator{contract: _MxcL1.contract, event: "BlockProposeReward", logs: logs, sub: sub}, nil
}

// WatchBlockProposeReward is a free log subscription operation binding the contract event 0x6c37877020064aabb3c00d8dff4cf6b32ec9dfc400d86b943af79c46492ca791.
//
// Solidity: event BlockProposeReward(uint256 indexed id, address proposer, uint256 reward)
func (_MxcL1 *MxcL1Filterer) WatchBlockProposeReward(opts *bind.WatchOpts, sink chan<- *MxcL1BlockProposeReward, id []*big.Int) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "BlockProposeReward", idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1BlockProposeReward)
				if err := _MxcL1.contract.UnpackLog(event, "BlockProposeReward", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBlockProposeReward is a log parse operation binding the contract event 0x6c37877020064aabb3c00d8dff4cf6b32ec9dfc400d86b943af79c46492ca791.
//
// Solidity: event BlockProposeReward(uint256 indexed id, address proposer, uint256 reward)
func (_MxcL1 *MxcL1Filterer) ParseBlockProposeReward(log types.Log) (*MxcL1BlockProposeReward, error) {
	event := new(MxcL1BlockProposeReward)
	if err := _MxcL1.contract.UnpackLog(event, "BlockProposeReward", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1BlockProposedIterator is returned from FilterBlockProposed and is used to iterate over the raw logs and unpacked data for BlockProposed events raised by the MxcL1 contract.
type MxcL1BlockProposedIterator struct {
	Event *MxcL1BlockProposed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1BlockProposedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1BlockProposed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1BlockProposed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1BlockProposedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1BlockProposedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1BlockProposed represents a BlockProposed event raised by the MxcL1 contract.
type MxcL1BlockProposed struct {
	Id       *big.Int
	Meta     MxcDataBlockMetadata
	BlockFee uint64
	Raw      types.Log // Blockchain specific contextual infos
}

// FilterBlockProposed is a free log retrieval operation binding the contract event 0xb250038c85825d1ba0b724295351e6c1fb3e629867d2510e4b6938546abfecf8.
//
// Solidity: event BlockProposed(uint256 indexed id, (uint64,uint64,uint64,bytes32,bytes32,bytes32,uint24,uint24,uint32,address,address,(address,uint96,uint64)[],uint256,uint256) meta, uint64 blockFee)
func (_MxcL1 *MxcL1Filterer) FilterBlockProposed(opts *bind.FilterOpts, id []*big.Int) (*MxcL1BlockProposedIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "BlockProposed", idRule)
	if err != nil {
		return nil, err
	}
	return &MxcL1BlockProposedIterator{contract: _MxcL1.contract, event: "BlockProposed", logs: logs, sub: sub}, nil
}

// WatchBlockProposed is a free log subscription operation binding the contract event 0xb250038c85825d1ba0b724295351e6c1fb3e629867d2510e4b6938546abfecf8.
//
// Solidity: event BlockProposed(uint256 indexed id, (uint64,uint64,uint64,bytes32,bytes32,bytes32,uint24,uint24,uint32,address,address,(address,uint96,uint64)[],uint256,uint256) meta, uint64 blockFee)
func (_MxcL1 *MxcL1Filterer) WatchBlockProposed(opts *bind.WatchOpts, sink chan<- *MxcL1BlockProposed, id []*big.Int) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "BlockProposed", idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1BlockProposed)
				if err := _MxcL1.contract.UnpackLog(event, "BlockProposed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBlockProposed is a log parse operation binding the contract event 0xb250038c85825d1ba0b724295351e6c1fb3e629867d2510e4b6938546abfecf8.
//
// Solidity: event BlockProposed(uint256 indexed id, (uint64,uint64,uint64,bytes32,bytes32,bytes32,uint24,uint24,uint32,address,address,(address,uint96,uint64)[],uint256,uint256) meta, uint64 blockFee)
func (_MxcL1 *MxcL1Filterer) ParseBlockProposed(log types.Log) (*MxcL1BlockProposed, error) {
	event := new(MxcL1BlockProposed)
	if err := _MxcL1.contract.UnpackLog(event, "BlockProposed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1BlockProvenIterator is returned from FilterBlockProven and is used to iterate over the raw logs and unpacked data for BlockProven events raised by the MxcL1 contract.
type MxcL1BlockProvenIterator struct {
	Event *MxcL1BlockProven // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1BlockProvenIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1BlockProven)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1BlockProven)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1BlockProvenIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1BlockProvenIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1BlockProven represents a BlockProven event raised by the MxcL1 contract.
type MxcL1BlockProven struct {
	Id            *big.Int
	ParentHash    [32]byte
	BlockHash     [32]byte
	SignalRoot    [32]byte
	Prover        common.Address
	ParentGasUsed uint32
	Raw           types.Log // Blockchain specific contextual infos
}

// FilterBlockProven is a free log retrieval operation binding the contract event 0x2295930c498c7b1f60143439a63dd1d24bbb730f08ff6ed383b490ba2c1cafa4.
//
// Solidity: event BlockProven(uint256 indexed id, bytes32 parentHash, bytes32 blockHash, bytes32 signalRoot, address prover, uint32 parentGasUsed)
func (_MxcL1 *MxcL1Filterer) FilterBlockProven(opts *bind.FilterOpts, id []*big.Int) (*MxcL1BlockProvenIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "BlockProven", idRule)
	if err != nil {
		return nil, err
	}
	return &MxcL1BlockProvenIterator{contract: _MxcL1.contract, event: "BlockProven", logs: logs, sub: sub}, nil
}

// WatchBlockProven is a free log subscription operation binding the contract event 0x2295930c498c7b1f60143439a63dd1d24bbb730f08ff6ed383b490ba2c1cafa4.
//
// Solidity: event BlockProven(uint256 indexed id, bytes32 parentHash, bytes32 blockHash, bytes32 signalRoot, address prover, uint32 parentGasUsed)
func (_MxcL1 *MxcL1Filterer) WatchBlockProven(opts *bind.WatchOpts, sink chan<- *MxcL1BlockProven, id []*big.Int) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "BlockProven", idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1BlockProven)
				if err := _MxcL1.contract.UnpackLog(event, "BlockProven", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBlockProven is a log parse operation binding the contract event 0x2295930c498c7b1f60143439a63dd1d24bbb730f08ff6ed383b490ba2c1cafa4.
//
// Solidity: event BlockProven(uint256 indexed id, bytes32 parentHash, bytes32 blockHash, bytes32 signalRoot, address prover, uint32 parentGasUsed)
func (_MxcL1 *MxcL1Filterer) ParseBlockProven(log types.Log) (*MxcL1BlockProven, error) {
	event := new(MxcL1BlockProven)
	if err := _MxcL1.contract.UnpackLog(event, "BlockProven", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1BlockProvenRewardIterator is returned from FilterBlockProvenReward and is used to iterate over the raw logs and unpacked data for BlockProvenReward events raised by the MxcL1 contract.
type MxcL1BlockProvenRewardIterator struct {
	Event *MxcL1BlockProvenReward // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1BlockProvenRewardIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1BlockProvenReward)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1BlockProvenReward)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1BlockProvenRewardIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1BlockProvenRewardIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1BlockProvenReward represents a BlockProvenReward event raised by the MxcL1 contract.
type MxcL1BlockProvenReward struct {
	Id     *big.Int
	Prover common.Address
	Reward *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterBlockProvenReward is a free log retrieval operation binding the contract event 0x3f660dbecdc997b020e22e0c005183d9b72e405db24f96490dc1484344242989.
//
// Solidity: event BlockProvenReward(uint256 indexed id, address prover, uint256 reward)
func (_MxcL1 *MxcL1Filterer) FilterBlockProvenReward(opts *bind.FilterOpts, id []*big.Int) (*MxcL1BlockProvenRewardIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "BlockProvenReward", idRule)
	if err != nil {
		return nil, err
	}
	return &MxcL1BlockProvenRewardIterator{contract: _MxcL1.contract, event: "BlockProvenReward", logs: logs, sub: sub}, nil
}

// WatchBlockProvenReward is a free log subscription operation binding the contract event 0x3f660dbecdc997b020e22e0c005183d9b72e405db24f96490dc1484344242989.
//
// Solidity: event BlockProvenReward(uint256 indexed id, address prover, uint256 reward)
func (_MxcL1 *MxcL1Filterer) WatchBlockProvenReward(opts *bind.WatchOpts, sink chan<- *MxcL1BlockProvenReward, id []*big.Int) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "BlockProvenReward", idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1BlockProvenReward)
				if err := _MxcL1.contract.UnpackLog(event, "BlockProvenReward", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBlockProvenReward is a log parse operation binding the contract event 0x3f660dbecdc997b020e22e0c005183d9b72e405db24f96490dc1484344242989.
//
// Solidity: event BlockProvenReward(uint256 indexed id, address prover, uint256 reward)
func (_MxcL1 *MxcL1Filterer) ParseBlockProvenReward(log types.Log) (*MxcL1BlockProvenReward, error) {
	event := new(MxcL1BlockProvenReward)
	if err := _MxcL1.contract.UnpackLog(event, "BlockProvenReward", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1BlockVerifiedIterator is returned from FilterBlockVerified and is used to iterate over the raw logs and unpacked data for BlockVerified events raised by the MxcL1 contract.
type MxcL1BlockVerifiedIterator struct {
	Event *MxcL1BlockVerified // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1BlockVerifiedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1BlockVerified)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1BlockVerified)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1BlockVerifiedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1BlockVerifiedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1BlockVerified represents a BlockVerified event raised by the MxcL1 contract.
type MxcL1BlockVerified struct {
	Id        *big.Int
	BlockHash [32]byte
	Reward    *big.Int
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterBlockVerified is a free log retrieval operation binding the contract event 0x7e98ef90898cf74532e8f918c3b89c5ce86c0b10a0d9bf3d0526af7fa7b099da.
//
// Solidity: event BlockVerified(uint256 indexed id, bytes32 blockHash, uint256 reward)
func (_MxcL1 *MxcL1Filterer) FilterBlockVerified(opts *bind.FilterOpts, id []*big.Int) (*MxcL1BlockVerifiedIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "BlockVerified", idRule)
	if err != nil {
		return nil, err
	}
	return &MxcL1BlockVerifiedIterator{contract: _MxcL1.contract, event: "BlockVerified", logs: logs, sub: sub}, nil
}

// WatchBlockVerified is a free log subscription operation binding the contract event 0x7e98ef90898cf74532e8f918c3b89c5ce86c0b10a0d9bf3d0526af7fa7b099da.
//
// Solidity: event BlockVerified(uint256 indexed id, bytes32 blockHash, uint256 reward)
func (_MxcL1 *MxcL1Filterer) WatchBlockVerified(opts *bind.WatchOpts, sink chan<- *MxcL1BlockVerified, id []*big.Int) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "BlockVerified", idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1BlockVerified)
				if err := _MxcL1.contract.UnpackLog(event, "BlockVerified", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBlockVerified is a log parse operation binding the contract event 0x7e98ef90898cf74532e8f918c3b89c5ce86c0b10a0d9bf3d0526af7fa7b099da.
//
// Solidity: event BlockVerified(uint256 indexed id, bytes32 blockHash, uint256 reward)
func (_MxcL1 *MxcL1Filterer) ParseBlockVerified(log types.Log) (*MxcL1BlockVerified, error) {
	event := new(MxcL1BlockVerified)
	if err := _MxcL1.contract.UnpackLog(event, "BlockVerified", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1CrossChainSyncedIterator is returned from FilterCrossChainSynced and is used to iterate over the raw logs and unpacked data for CrossChainSynced events raised by the MxcL1 contract.
type MxcL1CrossChainSyncedIterator struct {
	Event *MxcL1CrossChainSynced // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1CrossChainSyncedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1CrossChainSynced)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1CrossChainSynced)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1CrossChainSyncedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1CrossChainSyncedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1CrossChainSynced represents a CrossChainSynced event raised by the MxcL1 contract.
type MxcL1CrossChainSynced struct {
	SrcHeight  *big.Int
	BlockHash  [32]byte
	SignalRoot [32]byte
	Raw        types.Log // Blockchain specific contextual infos
}

// FilterCrossChainSynced is a free log retrieval operation binding the contract event 0x7528bbd1cef0e5d13408706892a51ee8ef82bbf33d4ec0c37216f8beba71205b.
//
// Solidity: event CrossChainSynced(uint256 indexed srcHeight, bytes32 blockHash, bytes32 signalRoot)
func (_MxcL1 *MxcL1Filterer) FilterCrossChainSynced(opts *bind.FilterOpts, srcHeight []*big.Int) (*MxcL1CrossChainSyncedIterator, error) {

	var srcHeightRule []interface{}
	for _, srcHeightItem := range srcHeight {
		srcHeightRule = append(srcHeightRule, srcHeightItem)
	}

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "CrossChainSynced", srcHeightRule)
	if err != nil {
		return nil, err
	}
	return &MxcL1CrossChainSyncedIterator{contract: _MxcL1.contract, event: "CrossChainSynced", logs: logs, sub: sub}, nil
}

// WatchCrossChainSynced is a free log subscription operation binding the contract event 0x7528bbd1cef0e5d13408706892a51ee8ef82bbf33d4ec0c37216f8beba71205b.
//
// Solidity: event CrossChainSynced(uint256 indexed srcHeight, bytes32 blockHash, bytes32 signalRoot)
func (_MxcL1 *MxcL1Filterer) WatchCrossChainSynced(opts *bind.WatchOpts, sink chan<- *MxcL1CrossChainSynced, srcHeight []*big.Int) (event.Subscription, error) {

	var srcHeightRule []interface{}
	for _, srcHeightItem := range srcHeight {
		srcHeightRule = append(srcHeightRule, srcHeightItem)
	}

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "CrossChainSynced", srcHeightRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1CrossChainSynced)
				if err := _MxcL1.contract.UnpackLog(event, "CrossChainSynced", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseCrossChainSynced is a log parse operation binding the contract event 0x7528bbd1cef0e5d13408706892a51ee8ef82bbf33d4ec0c37216f8beba71205b.
//
// Solidity: event CrossChainSynced(uint256 indexed srcHeight, bytes32 blockHash, bytes32 signalRoot)
func (_MxcL1 *MxcL1Filterer) ParseCrossChainSynced(log types.Log) (*MxcL1CrossChainSynced, error) {
	event := new(MxcL1CrossChainSynced)
	if err := _MxcL1.contract.UnpackLog(event, "CrossChainSynced", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1EthDepositedIterator is returned from FilterEthDeposited and is used to iterate over the raw logs and unpacked data for EthDeposited events raised by the MxcL1 contract.
type MxcL1EthDepositedIterator struct {
	Event *MxcL1EthDeposited // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1EthDepositedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1EthDeposited)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1EthDeposited)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1EthDepositedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1EthDepositedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1EthDeposited represents a EthDeposited event raised by the MxcL1 contract.
type MxcL1EthDeposited struct {
	Deposit MxcDataEthDeposit
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterEthDeposited is a free log retrieval operation binding the contract event 0x7120a3b075ad25974c5eed76dedb3a217c76c9c6d1f1e201caeba9b89de9a9d9.
//
// Solidity: event EthDeposited((address,uint96,uint64) deposit)
func (_MxcL1 *MxcL1Filterer) FilterEthDeposited(opts *bind.FilterOpts) (*MxcL1EthDepositedIterator, error) {

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "EthDeposited")
	if err != nil {
		return nil, err
	}
	return &MxcL1EthDepositedIterator{contract: _MxcL1.contract, event: "EthDeposited", logs: logs, sub: sub}, nil
}

// WatchEthDeposited is a free log subscription operation binding the contract event 0x7120a3b075ad25974c5eed76dedb3a217c76c9c6d1f1e201caeba9b89de9a9d9.
//
// Solidity: event EthDeposited((address,uint96,uint64) deposit)
func (_MxcL1 *MxcL1Filterer) WatchEthDeposited(opts *bind.WatchOpts, sink chan<- *MxcL1EthDeposited) (event.Subscription, error) {

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "EthDeposited")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1EthDeposited)
				if err := _MxcL1.contract.UnpackLog(event, "EthDeposited", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseEthDeposited is a log parse operation binding the contract event 0x7120a3b075ad25974c5eed76dedb3a217c76c9c6d1f1e201caeba9b89de9a9d9.
//
// Solidity: event EthDeposited((address,uint96,uint64) deposit)
func (_MxcL1 *MxcL1Filterer) ParseEthDeposited(log types.Log) (*MxcL1EthDeposited, error) {
	event := new(MxcL1EthDeposited)
	if err := _MxcL1.contract.UnpackLog(event, "EthDeposited", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1InitializedIterator is returned from FilterInitialized and is used to iterate over the raw logs and unpacked data for Initialized events raised by the MxcL1 contract.
type MxcL1InitializedIterator struct {
	Event *MxcL1Initialized // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1InitializedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1Initialized)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1Initialized)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1InitializedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1InitializedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1Initialized represents a Initialized event raised by the MxcL1 contract.
type MxcL1Initialized struct {
	Version uint8
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterInitialized is a free log retrieval operation binding the contract event 0x7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb3847402498.
//
// Solidity: event Initialized(uint8 version)
func (_MxcL1 *MxcL1Filterer) FilterInitialized(opts *bind.FilterOpts) (*MxcL1InitializedIterator, error) {

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "Initialized")
	if err != nil {
		return nil, err
	}
	return &MxcL1InitializedIterator{contract: _MxcL1.contract, event: "Initialized", logs: logs, sub: sub}, nil
}

// WatchInitialized is a free log subscription operation binding the contract event 0x7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb3847402498.
//
// Solidity: event Initialized(uint8 version)
func (_MxcL1 *MxcL1Filterer) WatchInitialized(opts *bind.WatchOpts, sink chan<- *MxcL1Initialized) (event.Subscription, error) {

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "Initialized")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1Initialized)
				if err := _MxcL1.contract.UnpackLog(event, "Initialized", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseInitialized is a log parse operation binding the contract event 0x7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb3847402498.
//
// Solidity: event Initialized(uint8 version)
func (_MxcL1 *MxcL1Filterer) ParseInitialized(log types.Log) (*MxcL1Initialized, error) {
	event := new(MxcL1Initialized)
	if err := _MxcL1.contract.UnpackLog(event, "Initialized", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1OwnershipTransferredIterator is returned from FilterOwnershipTransferred and is used to iterate over the raw logs and unpacked data for OwnershipTransferred events raised by the MxcL1 contract.
type MxcL1OwnershipTransferredIterator struct {
	Event *MxcL1OwnershipTransferred // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1OwnershipTransferredIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1OwnershipTransferred)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1OwnershipTransferred)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1OwnershipTransferredIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1OwnershipTransferredIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1OwnershipTransferred represents a OwnershipTransferred event raised by the MxcL1 contract.
type MxcL1OwnershipTransferred struct {
	PreviousOwner common.Address
	NewOwner      common.Address
	Raw           types.Log // Blockchain specific contextual infos
}

// FilterOwnershipTransferred is a free log retrieval operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
func (_MxcL1 *MxcL1Filterer) FilterOwnershipTransferred(opts *bind.FilterOpts, previousOwner []common.Address, newOwner []common.Address) (*MxcL1OwnershipTransferredIterator, error) {

	var previousOwnerRule []interface{}
	for _, previousOwnerItem := range previousOwner {
		previousOwnerRule = append(previousOwnerRule, previousOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "OwnershipTransferred", previousOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return &MxcL1OwnershipTransferredIterator{contract: _MxcL1.contract, event: "OwnershipTransferred", logs: logs, sub: sub}, nil
}

// WatchOwnershipTransferred is a free log subscription operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
func (_MxcL1 *MxcL1Filterer) WatchOwnershipTransferred(opts *bind.WatchOpts, sink chan<- *MxcL1OwnershipTransferred, previousOwner []common.Address, newOwner []common.Address) (event.Subscription, error) {

	var previousOwnerRule []interface{}
	for _, previousOwnerItem := range previousOwner {
		previousOwnerRule = append(previousOwnerRule, previousOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "OwnershipTransferred", previousOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1OwnershipTransferred)
				if err := _MxcL1.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseOwnershipTransferred is a log parse operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
func (_MxcL1 *MxcL1Filterer) ParseOwnershipTransferred(log types.Log) (*MxcL1OwnershipTransferred, error) {
	event := new(MxcL1OwnershipTransferred)
	if err := _MxcL1.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MxcL1ProofParamsChangedIterator is returned from FilterProofParamsChanged and is used to iterate over the raw logs and unpacked data for ProofParamsChanged events raised by the MxcL1 contract.
type MxcL1ProofParamsChangedIterator struct {
	Event *MxcL1ProofParamsChanged // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *MxcL1ProofParamsChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MxcL1ProofParamsChanged)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(MxcL1ProofParamsChanged)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *MxcL1ProofParamsChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MxcL1ProofParamsChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MxcL1ProofParamsChanged represents a ProofParamsChanged event raised by the MxcL1 contract.
type MxcL1ProofParamsChanged struct {
	ProofTimeTarget    uint64
	ProofTimeIssued    uint64
	BlockFee           uint64
	AdjustmentQuotient uint16
	Raw                types.Log // Blockchain specific contextual infos
}

// FilterProofParamsChanged is a free log retrieval operation binding the contract event 0x565e5aa69c99d81e441dd3bb8535d888585683743f3c6a3bf49e5e1b227bd8f9.
//
// Solidity: event ProofParamsChanged(uint64 proofTimeTarget, uint64 proofTimeIssued, uint64 blockFee, uint16 adjustmentQuotient)
func (_MxcL1 *MxcL1Filterer) FilterProofParamsChanged(opts *bind.FilterOpts) (*MxcL1ProofParamsChangedIterator, error) {

	logs, sub, err := _MxcL1.contract.FilterLogs(opts, "ProofParamsChanged")
	if err != nil {
		return nil, err
	}
	return &MxcL1ProofParamsChangedIterator{contract: _MxcL1.contract, event: "ProofParamsChanged", logs: logs, sub: sub}, nil
}

// WatchProofParamsChanged is a free log subscription operation binding the contract event 0x565e5aa69c99d81e441dd3bb8535d888585683743f3c6a3bf49e5e1b227bd8f9.
//
// Solidity: event ProofParamsChanged(uint64 proofTimeTarget, uint64 proofTimeIssued, uint64 blockFee, uint16 adjustmentQuotient)
func (_MxcL1 *MxcL1Filterer) WatchProofParamsChanged(opts *bind.WatchOpts, sink chan<- *MxcL1ProofParamsChanged) (event.Subscription, error) {

	logs, sub, err := _MxcL1.contract.WatchLogs(opts, "ProofParamsChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MxcL1ProofParamsChanged)
				if err := _MxcL1.contract.UnpackLog(event, "ProofParamsChanged", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseProofParamsChanged is a log parse operation binding the contract event 0x565e5aa69c99d81e441dd3bb8535d888585683743f3c6a3bf49e5e1b227bd8f9.
//
// Solidity: event ProofParamsChanged(uint64 proofTimeTarget, uint64 proofTimeIssued, uint64 blockFee, uint16 adjustmentQuotient)
func (_MxcL1 *MxcL1Filterer) ParseProofParamsChanged(log types.Log) (*MxcL1ProofParamsChanged, error) {
	event := new(MxcL1ProofParamsChanged)
	if err := _MxcL1.contract.UnpackLog(event, "ProofParamsChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
