package message

import (
	"context"
	"testing"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer/mock"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/stretchr/testify/assert"
)

func Test_getLatestNonce(t *testing.T) {
	p := newTestProcessor(true)

	err := p.getLatestNonce(context.Background(), &bind.TransactOpts{})
	assert.Nil(t, err)

	assert.Equal(t, p.destNonce, mock.PendingNonce)
}
