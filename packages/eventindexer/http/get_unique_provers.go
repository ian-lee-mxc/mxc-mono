package http

import (
	"net/http"

	"github.com/MXCzkEVM/mxc-mono/packages/eventindexer"
	"github.com/cyberhorsey/webutils"
	"github.com/labstack/echo/v4"
)

type uniqueProversResp struct {
	Provers       []eventindexer.UniqueProversResponse `json:"provers"`
	UniqueProvers int                                  `json:"uniqueProvers"`
}

func (srv *Server) GetUniqueProvers(c echo.Context) error {
	provers, err := srv.eventRepo.FindUniqueProvers(
		c.Request().Context(),
	)
	if err != nil {
		return webutils.LogAndRenderErrors(c, http.StatusUnprocessableEntity, err)
	}

	return c.JSON(http.StatusOK, &uniqueProversResp{
		Provers:       provers,
		UniqueProvers: len(provers),
	})
}
