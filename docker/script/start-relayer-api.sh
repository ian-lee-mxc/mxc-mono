#!/bin/sh

set -eou pipefail

exec relayer api \
  --db.username ${DATABASE_USER} \
  --db.password ${DATABASE_PASSWORD} \
  --db.host ${DATABASE_HOST} \
  --db.name ${DATABASE_NAME} \
  --db.maxIdleConns ${DATABASE_MAX_IDLE_CONNS} \
  --db.maxOpenConns ${DATABASE_MAX_OPEN_CONNS} \
  --db.connMaxLifetime ${DATABASE_CONN_MAX_LIFETIME} \
  --srcRpcUrl ${SRC_RPC_URL} \
  --destRpcUrl ${DEST_RPC_URL} \
  --metrics.port ${METRICS_HTTP_PORT} \
  --ethClientTimeout ${ETH_CLIENT_TIMEOUT} \
  --srcSignalServiceAddress ${SRC_SIGNAL_SERVICE_ADDRESS} \
  --http.port ${HTTP_PORT} \
  --processingFeeMultiplier ${PROCESSING_FEE_MULTIPLIER} \
  --destTaikoAddress ${DEST_TAIKO_ADDRESS}
