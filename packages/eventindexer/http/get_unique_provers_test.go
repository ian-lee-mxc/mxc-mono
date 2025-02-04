package http

import (
	"context"
	"math/big"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/MXCzkEVM/mxc-mono/packages/eventindexer"
	"github.com/cyberhorsey/webutils/testutils"
	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
)

func Test_GetUniqueProvers(t *testing.T) {
	srv := newTestServer("")

	_, err := srv.eventRepo.Save(context.Background(), eventindexer.SaveEventOpts{
		Name:    "name",
		Data:    `{"Owner": "0x0000000000000000000000000000000000000123"}`,
		ChainID: big.NewInt(167001),
		Address: "0x123",
		Event:   eventindexer.EventNameBlockProven,
	})

	assert.Equal(t, nil, err)

	tests := []struct {
		name                  string
		wantStatus            int
		wantBodyRegexpMatches []string
	}{
		{
			"successEmptyList",
			http.StatusOK,
			[]string{`\[\]`},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := testutils.NewUnauthenticatedRequest(
				echo.GET,
				"/uniqueProvers",
				nil,
			)

			rec := httptest.NewRecorder()

			srv.ServeHTTP(rec, req)

			testutils.AssertStatusAndBody(t, rec, tt.wantStatus, tt.wantBodyRegexpMatches)
		})
	}
}
