package indexer

import (
	"context"
	"math/big"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer"
	"github.com/pkg/errors"
)

func (svc *Service) setInitialProcessingBlockByMode(
	ctx context.Context,
	mode relayer.Mode,
	chainID *big.Int,
) error {
	var startingBlock uint64 = 0

	if svc.mxcL1 != nil {
		stateVars, err := svc.mxcL1.GetStateVariables(nil)
		if err != nil {
			return errors.Wrap(err, "svc.mxcL1.GetStateVariables")
		}

		startingBlock = stateVars.GenesisHeight
	}

	switch mode {
	case relayer.SyncMode:
		// get most recently processed block height from the DB
		latestProcessedBlock, err := svc.blockRepo.GetLatestBlockProcessedForEvent(
			eventName,
			chainID,
		)
		if err != nil {
			return errors.Wrap(err, "svc.blockRepo.GetLatestBlock()")
		}

		if latestProcessedBlock.Height != 0 {
			startingBlock = latestProcessedBlock.Height
		}

		svc.processingBlockHeight = startingBlock

		return nil
	case relayer.ResyncMode:
		svc.processingBlockHeight = startingBlock
		return nil
	default:
		return relayer.ErrInvalidMode
	}
}
