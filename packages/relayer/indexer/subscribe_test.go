package indexer

import (
	"context"
	"testing"
	"time"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer/mock"
	"github.com/stretchr/testify/assert"
)

func Test_subscribe(t *testing.T) {
	svc, bridge := newTestService()

	go func() {
		_ = svc.subscribe(context.Background(), mock.MockChainID)
	}()

	<-time.After(6 * time.Second)

	b := bridge.(*mock.Bridge)

	assert.Equal(t, 1, b.MessagesSent)
	assert.Equal(t, 1, b.MessageStatusesChanged)
	assert.Equal(t, 2, b.ErrorsSent)
}
