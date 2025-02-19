package moonchain

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"time"

	"github.com/cenkalti/backoff/v4"

	"github.com/ethereum/go-ethereum/log"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
)

const (
	ErrorSgxSubmitProofReverted = "SGX_SUBMIT_PROOF_REVERTED"
)

var (
	hostRequestTimeout        = 30 * time.Second
	hostRetryInterval         = 10 * time.Second
	hostNumOfRetry     uint64 = 2
)

// ProverManger is Moonchain service to proxy multiple raiko for SGX proof generation
type ProverManager struct {
	HostEndpoint string
}

// ProverManagerSubmitFailureRequest represents the JSON body for submitting failure report.
type ProverManagerSubmitFailureRequest struct {
	Block      *big.Int `json:"blockNumber"`
	InstanceId int64    `json:"instanceId"`
	Error      string   `json:"error"`
	Reason     string   `json:"reason"`
}

// ProverManagerSubmitFailureResponse represents the JSON body of the response of the submitting failure.
type ProverManagerSubmitFailureResponse struct {
	Ret     *int    `json:"ret"`
	Message *string `json:"message"`
}

// Submit Failure implements the ProofProducer interface.
func (s *ProverManager) SubmitFailure(
	ctx context.Context,
	blockID *big.Int,
	instanceId int64,
	errorMessage string,
	reason string,
) error {
	log.Info(
		"Submitting failure report to Prover Manager",
		"blockID", blockID,
		"instanceId", instanceId,
		"errorMessage", errorMessage,
		"reason", reason,
	)
	if err := backoff.Retry(
		func() error {
			return s.callSubmitFailureDaemon(ctx, blockID, instanceId, errorMessage, reason)
		},
		backoff.WithMaxRetries(backoff.WithContext(backoff.NewConstantBackOff(hostRetryInterval), ctx), hostNumOfRetry),
	); err != nil {
		log.Error("Moonchain SubmitFailure", "error", err)
	}

	return nil
}

func (s *ProverManager) SubmitFailureCancel(
	_ context.Context,
) error {
	return nil
}

// callSubmitFailureDaemon submit report with timeout.
func (s *ProverManager) callSubmitFailureDaemon(
	ctx context.Context,
	blockID *big.Int,
	instanceId int64,
	errorMessage string,
	reason string,
) error {
	ctx, cancel := rpc.CtxWithTimeoutOrDefault(ctx, hostRequestTimeout)
	defer cancel()

	err := s.submitFailureReport(ctx, blockID, instanceId, errorMessage, reason)
	if err != nil {
		log.Error("Failed to submit failure report", "blockId", blockID, "error", err, "endpoint", s.HostEndpoint)
		return err
	}

	log.Info(
		"Failure report submitted",
		"blockId", blockID,
		"instanceId", instanceId,
		"reason", reason,
	)

	return nil
}

// requestProof sends a RPC request to proverd to try to get the requested proof.
func (s *ProverManager) submitFailureReport(
	ctx context.Context,
	blockID *big.Int,
	instanceId int64,
	errorMessage string,
	reason string,
) error {
	reqBody := ProverManagerSubmitFailureRequest{
		Block:      blockID,
		InstanceId: instanceId,
		Error:      errorMessage,
		Reason:     reason,
	}

	client := &http.Client{}

	jsonValue, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", s.HostEndpoint+"/taiko-client/failure", bytes.NewBuffer(jsonValue))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	res, err := client.Do(req)
	if err != nil {
		return err
	}

	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("submitFailureReport failed, id: %d, statusCode: %d", blockID, res.StatusCode)
	}

	resBytes, err := io.ReadAll(res.Body)
	if err != nil {
		return err
	}

	log.Debug("Resp of submit failure report", "resBytes", string(resBytes))

	var output ProverManagerSubmitFailureResponse
	if err := json.Unmarshal(resBytes, &output); err != nil {
		return err
	}

	if output.Ret == nil || output.Message == nil {
		return fmt.Errorf("submitFailureReport failed, invalid resp: %s", string(resBytes))
	}

	if *output.Ret != 0 {
		return fmt.Errorf("submitFailureReport failed, msg: %s", *output.Message)
	}

	return nil
}
