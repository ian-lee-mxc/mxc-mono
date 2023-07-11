package message

import (
	"context"
	"testing"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer/mock"
	"github.com/stretchr/testify/assert"
)

func Test_waitForConfirmations(t *testing.T) {
	p := newTestProcessor(true)

	err := p.waitForConfirmations(context.TODO(), mock.SucceedTxHash, uint64(mock.BlockNum))
	assert.Nil(t, err)
}
