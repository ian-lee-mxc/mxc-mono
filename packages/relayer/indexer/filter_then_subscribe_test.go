package indexer

import (
	"context"
	"testing"
	"time"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer"
	"github.com/MXCzkEVM/mxc-mono/packages/relayer/mock"
	"github.com/stretchr/testify/assert"
)

func Test_FilterThenSubscribe(t *testing.T) {
	svc, bridge := newTestService()
	b := bridge.(*mock.Bridge)

	svc.processingBlockHeight = 0

	go func() {
		_ = svc.FilterThenSubscribe(
			context.Background(),
			relayer.Mode(relayer.SyncMode),
			relayer.FilterAndSubscribeWatchMode,
		)
	}()

	<-time.After(6 * time.Second)

	assert.Equal(t, b.MessagesSent, 1)
	assert.Equal(t, b.MessageStatusesChanged, 1)
	assert.Equal(t, b.ErrorsSent, 2)
}

func Test_FilterThenSubscribe_subscribeWatchMode(t *testing.T) {
	svc, bridge := newTestService()
	b := bridge.(*mock.Bridge)

	go func() {
		_ = svc.FilterThenSubscribe(
			context.Background(),
			relayer.Mode(relayer.SyncMode),
			relayer.SubscribeWatchMode,
		)
	}()

	<-time.After(6 * time.Second)

	assert.Equal(t, b.MessagesSent, 1)
	assert.Equal(t, b.MessageStatusesChanged, 1)
	assert.Equal(t, b.ErrorsSent, 2)
}

func Test_FilterThenSubscribe_alreadyCaughtUp(t *testing.T) {
	svc, bridge := newTestService()
	b := bridge.(*mock.Bridge)

	svc.processingBlockHeight = mock.LatestBlockNumber.Uint64()

	go func() {
		_ = svc.FilterThenSubscribe(
			context.Background(),
			relayer.Mode(relayer.SyncMode),
			relayer.FilterAndSubscribeWatchMode,
		)
	}()

	<-time.After(6 * time.Second)

	assert.Equal(t, b.MessagesSent, 1)
	assert.Equal(t, b.MessageStatusesChanged, 1)
	assert.Equal(t, b.ErrorsSent, 2)
}
