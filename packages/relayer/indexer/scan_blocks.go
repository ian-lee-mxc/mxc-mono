package indexer

import (
	"context"
	"math/big"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer"
	"github.com/ethereum/go-ethereum/core/types"
)

func scanBlocks(ctx context.Context, ethClient ethClient, chainID *big.Int) {
	headers := make(chan *types.Header)

	sub, err := ethClient.SubscribeNewHead(ctx, headers)
	if err != nil {
		panic(err)
	}

	for {
		select {
		case <-sub.Err():
			relayer.BlocksScannedError.Inc()

			scanBlocks(ctx, ethClient, chainID)

			return
		case <-headers:
			relayer.BlocksScanned.Inc()
		}
	}
}
