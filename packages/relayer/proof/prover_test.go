package proof

import (
	"github.com/ethereum/go-ethereum/rpc"
	"testing"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer"
	"github.com/MXCzkEVM/mxc-mono/packages/relayer/mock"
	"github.com/ethereum/go-ethereum/ethclient"
	"gopkg.in/go-playground/assert.v1"
)

func newTestProver() *Prover {
	return &Prover{
		blocker: &mock.Blocker{},
	}
}

func Test_New(t *testing.T) {
	tests := []struct {
		name    string
		blocker blocker
		client  *rpc.Client
		wantErr error
	}{
		{
			"success",
			&ethclient.Client{},
			&rpc.Client{},
			nil,
		},
		{
			"noEthClient",
			nil,
			nil,
			relayer.ErrNoEthClient,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := New(tt.blocker, tt.client)
			assert.Equal(t, tt.wantErr, err)
		})
	}
}
