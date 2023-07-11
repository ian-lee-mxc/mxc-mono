package proof

import (
	"context"
	"github.com/ethereum/go-ethereum/rpc"
	"math/big"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
)

type blocker interface {
	BlockByHash(ctx context.Context, hash common.Hash) (*types.Block, error)
}
type Prover struct {
	blocker   blocker
	rpcClient *rpc.Client
}

func New(blocker blocker, client *rpc.Client) (*Prover, error) {
	if blocker == nil {
		return nil, relayer.ErrNoEthClient
	}

	return &Prover{
		blocker:   blocker,
		rpcClient: client,
	}, nil
}

func (p *Prover) BlockNumberByHash(ctx context.Context, hash common.Hash) (*big.Int, error) {
	type Block struct {
		Number string `json:"number"`
	}
	block := Block{}

	err := p.rpcClient.CallContext(ctx, &block, "eth_getBlockByHash", hash, true)
	if err != nil {
		return nil, err
	}
	blockNumber := new(big.Int)
	blockNumber.SetString(block.Number[2:], 16)
	return blockNumber, nil
}
