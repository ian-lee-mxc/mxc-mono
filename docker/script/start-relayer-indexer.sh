#!/bin/sh

set -eou pipefail

ARGS="--db.username ${DATABASE_USER}
        --db.password ${DATABASE_PASSWORD}
        --db.host ${DATABASE_HOST}
        --db.name ${DATABASE_NAME}
        --db.maxIdleConns ${DATABASE_MAX_IDLE_CONNS}
        --db.maxOpenConns ${DATABASE_MAX_OPEN_CONNS}
        --db.connMaxLifetime ${DATABASE_CONN_MAX_LIFETIME}
        --srcRpcUrl ${SRC_RPC_URL}
        --destRpcUrl ${DEST_RPC_URL}
        --metrics.port ${METRICS_HTTP_PORT}
        --ethClientTimeout ${ETH_CLIENT_TIMEOUT}
        --srcSignalServiceAddress ${SRC_SIGNAL_SERVICE_ADDRESS}
        --srcBridgeAddress ${SRC_BRIDGE_ADDRESS}
        --destBridgeAddress ${DEST_BRIDGE_ADDRESS}
        --blockBatchSize ${BLOCK_BATCH_SIZE}
        --maxNumGoroutines ${NUM_GOROUTINES}
        --syncMode ${SYNC_MODE}
        --watchMode ${WATCH_MODE}
        --numLatestBlocksEndWhenCrawling ${NUM_LATEST_BLOCKS_END_WHEN_CRAWLING}
        --numLatestBlocksStartWhenCrawling ${NUM_LATEST_BLOCKS_START_WHEN_CRAWLING}
        --event ${EVENT_NAME}
        --minFeeToIndex ${MIN_FEE_TO_INDEX}
        "
if [ -n "$SRC_TAIKO_ADDRESS" ]; then
  ARGS="${ARGS} --srcTaikoAddress ${SRC_TAIKO_ADDRESS}"
fi

exec relayer indexer ${ARGS}

