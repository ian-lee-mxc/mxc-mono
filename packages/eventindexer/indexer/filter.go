package indexer

import (
	"context"
	"math/big"

	"log/slog"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/pkg/errors"
	"golang.org/x/sync/errgroup"
)

type FilterFunc func(
	ctx context.Context,
	chainID *big.Int,
	i *Indexer,
	filterOpts *bind.FilterOpts,
) error

// nolint
func filterFunc(
	ctx context.Context,
	chainID *big.Int,
	i *Indexer,
	filterOpts *bind.FilterOpts,
) error {
	wg, ctx := errgroup.WithContext(ctx)

	if i.taikol1 != nil {
		wg.Go(func() error {
			transitionProvedEvents, err := i.taikol1.FilterTransitionProved(filterOpts, nil)
			if err != nil {
				return errors.Wrap(err, "i.taikol1.FilterTransitionProved")
			}

			err = i.saveTransitionProvedEvents(ctx, chainID, transitionProvedEvents)
			if err != nil {
				return errors.Wrap(err, "i.saveTransitionProvedEvents")
			}

			return nil
		})

		wg.Go(func() error {
			transitionContestedEvents, err := i.taikol1.FilterTransitionContested(filterOpts, nil)
			if err != nil {
				return errors.Wrap(err, "i.taikol1.FilterTransitionContested")
			}

			err = i.saveTransitionContestedEvents(ctx, chainID, transitionContestedEvents)
			if err != nil {
				return errors.Wrap(err, "i.saveTransitionContestedEvents")
			}

			return nil
		})

		wg.Go(func() error {
			blockProposedEvents, err := i.taikol1.FilterBlockProposed(filterOpts, nil, nil)
			if err != nil {
				return errors.Wrap(err, "i.taikol1.FilterBlockProposed")
			}

			err = i.saveBlockProposedEvents(ctx, chainID, blockProposedEvents)
			if err != nil {
				return errors.Wrap(err, "i.saveBlockProposedEvents")
			}

			return nil
		})

		wg.Go(func() error {
			blockVerifiedEvents, err := i.taikol1.FilterBlockVerified(filterOpts, nil, nil)
			if err != nil {
				return errors.Wrap(err, "i.taikol1.FilterBlockVerified")
			}

			err = i.saveBlockVerifiedEvents(ctx, chainID, blockVerifiedEvents)
			if err != nil {
				return errors.Wrap(err, "i.saveBlockVerifiedEvents")
			}

			return nil
		})
	}

	if i.bridge != nil {
		wg.Go(func() error {
			messagesSent, err := i.bridge.FilterMessageSent(filterOpts, nil)
			if err != nil {
				return errors.Wrap(err, "i.bridge.FilterMessageSent")
			}

			err = i.saveMessageSentEvents(ctx, chainID, messagesSent)
			if err != nil {
				return errors.Wrap(err, "i.saveMessageSentEvents")
			}

			return nil
		})
	}

	wg.Go(func() error {
		if err := i.indexRawBlockData(ctx, chainID, filterOpts.Start, *filterOpts.End); err != nil {
			return errors.Wrap(err, "i.indexRawBlockData")
		}

		return nil
	})

	err := wg.Wait()

	if err != nil {
		if errors.Is(err, context.Canceled) {
			slog.Error("filter context cancelled")
			return err
		}

		return err
	}

	return nil
}

func (i *Indexer) filter(
	ctx context.Context,
	filter FilterFunc,
) error {
	endBlockID, err := i.ethClient.BlockNumber(ctx)
	if err != nil {
		return errors.Wrap(err, "i.ethClient.BlockNumber")
	}

	slog.Info("getting batch of events",
		"startBlock", i.latestIndexedBlockNumber,
		"endBlock", endBlockID,
		"batchSize", i.blockBatchSize,
	)

	for j := i.latestIndexedBlockNumber + 1; j <= endBlockID; j += i.blockBatchSize {
		end := i.latestIndexedBlockNumber + i.blockBatchSize
		// if the end of the batch is greater than the latest block number, set end
		// to the latest block number
		if end > endBlockID {
			end = endBlockID
		}

		slog.Info("block batch", "start", j, "end", end)

		filterOpts := &bind.FilterOpts{
			Start:   j,
			End:     &end,
			Context: ctx,
		}

		if err := filter(ctx, new(big.Int).SetUint64(i.srcChainID), i, filterOpts); err != nil {
			return errors.Wrap(err, "filter")
		}

		i.latestIndexedBlockNumber = end
	}

	return nil
}
