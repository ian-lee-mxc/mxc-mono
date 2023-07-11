package proof

import (
	"context"
	"testing"

	"github.com/MXCzkEVM/mxc-mono/packages/relayer/mock"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/stretchr/testify/assert"
)

var (
	// nolint: lll
	wantEncoded = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000"
)

func Test_EncodedSignalProof(t *testing.T) {
	p := newTestProver()

	encoded, err := p.EncodedSignalProof(context.Background(), &mock.Caller{}, common.Address{}, "1", mock.Header.TxHash)
	assert.Nil(t, err)
	assert.Equal(t, hexutil.Encode(encoded), wantEncoded)
}
