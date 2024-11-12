package encoding

import (
	"math/big"

	"github.com/ethereum/go-ethereum/params"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings"
)

var (
	livenessBond, _             = new(big.Int).SetString("125000000000000000000", 10)
	InternlDevnetProtocolConfig = &bindings.TaikoDataConfig{
		ChainId:               params.TaikoInternalL2ANetworkID.Uint64(),
		BlockMaxProposals:     324_000,
		BlockRingBufferSize:   360_000,
		MaxBlocksToVerify:     16,
		BlockMaxGasLimit:      240_000_000,
		LivenessBond:          livenessBond,
		StateRootSyncInternal: 16,
		MaxAnchorHeightOffset: 64,
		OntakeForkHeight:      2,
		BaseFeeConfig: bindings.TaikoDataBaseFeeConfig{
			AdjustmentQuotient:     8,
			SharingPctg:            75,
			GasIssuancePerSecond:   5_000_000,
			MinGasExcess:           1_340_000_000,
			MaxGasIssuancePerBlock: 600_000_000,
		},
	}
	HeklaProtocolConfig = &bindings.TaikoDataConfig{
		ChainId:               params.HeklaNetworkID.Uint64(),
		BlockMaxProposals:     324_000,
		BlockRingBufferSize:   324_512,
		MaxBlocksToVerify:     16,
		BlockMaxGasLimit:      240_000_000,
		LivenessBond:          livenessBond,
		StateRootSyncInternal: 16,
		MaxAnchorHeightOffset: 64,
		OntakeForkHeight:      793_000,
		BaseFeeConfig: bindings.TaikoDataBaseFeeConfig{
			AdjustmentQuotient:     8,
			SharingPctg:            75,
			GasIssuancePerSecond:   5_000_000,
			MinGasExcess:           1_340_000_000,
			MaxGasIssuancePerBlock: 600_000_000,
		},
	}
	MainnetProtocolConfig = &bindings.TaikoDataConfig{
		ChainId:               params.TaikoMainnetNetworkID.Uint64(),
		BlockMaxProposals:     324_000,
		BlockRingBufferSize:   360_000,
		MaxBlocksToVerify:     16,
		BlockMaxGasLimit:      240_000_000,
		LivenessBond:          livenessBond,
		StateRootSyncInternal: 16,
		MaxAnchorHeightOffset: 64,
		// TODO: update this value when mainnet fork height is decided
		OntakeForkHeight: 9_000_000,
		BaseFeeConfig: bindings.TaikoDataBaseFeeConfig{
			AdjustmentQuotient:     8,
			GasIssuancePerSecond:   5_000_000,
			MinGasExcess:           1_340_000_000,
			MaxGasIssuancePerBlock: 600_000_000,
		},
	}
	MoonchainGenevaProtocolConfig = &bindings.TaikoDataConfig{
		ChainId:               params.MoonchainGenevaNetworkID.Uint64(),
		BlockMaxProposals:     3_240_000,
		BlockRingBufferSize:   3_600_000,
		MaxBlocksToVerify:     16,
		BlockMaxGasLimit:      240_000_000,
		LivenessBond:          new(big.Int).SetInt64(0),
		StateRootSyncInternal: 16,
		MaxAnchorHeightOffset: 64,
		OntakeForkHeight:      715126,
		BaseFeeConfig: bindings.TaikoDataBaseFeeConfig{
			AdjustmentQuotient:     8,
			GasIssuancePerSecond:   5_000_000,
			MinGasExcess:           1_340_000_000,
			MaxGasIssuancePerBlock: 600_000_000,
		},
	}
	MoonchainMainnetProtocolConfig = &bindings.TaikoDataConfig{
		ChainId:               params.MoonchainMainnetNetworkID.Uint64(),
		BlockMaxProposals:     3_240_000,
		BlockRingBufferSize:   3_600_000,
		MaxBlocksToVerify:     16,
		BlockMaxGasLimit:      240_000_000,
		LivenessBond:          new(big.Int).SetInt64(0),
		StateRootSyncInternal: 16,
		MaxAnchorHeightOffset: 64,
		OntakeForkHeight:      0,
		BaseFeeConfig: bindings.TaikoDataBaseFeeConfig{
			AdjustmentQuotient:     8,
			GasIssuancePerSecond:   5_000_000,
			MinGasExcess:           1_340_000_000,
			MaxGasIssuancePerBlock: 600_000_000,
		},
	}
)

// GetProtocolConfig returns the protocol config for the given chain ID.
func GetProtocolConfig(chainID uint64) *bindings.TaikoDataConfig {
	switch chainID {
	case params.HeklaNetworkID.Uint64():
		return HeklaProtocolConfig
	case params.TaikoMainnetNetworkID.Uint64():
		return MainnetProtocolConfig
	case params.MoonchainGenevaNetworkID.Uint64():
		return MoonchainGenevaProtocolConfig
	case params.MoonchainMainnetNetworkID.Uint64():
		return MoonchainMainnetProtocolConfig
	default:
		return MoonchainGenevaProtocolConfig
	}
}
