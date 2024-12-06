#!/bin/sh

set -eou pipefail

exec eventindexer indexer \
  --db.username ${DATABASE_USER} \
  --db.password ${DATABASE_PASSWORD} \
  --db.host ${DATABASE_HOST} \
  --db.name ${DATABASE_NAME} \
  --db.maxIdleConns ${DATABASE_MAX_IDLE_CONNS} \
  --db.maxOpenConns ${DATABASE_MAX_OPEN_CONNS} \
  --db.connMaxLifetime ${DATABASE_CONN_MAX_LIFETIME} \
  --layer ${LAYER} \
  --rpcUrl ${RPC_URL} \
  --ethClientTimeout ${ETH_CLIENT_TIMEOUT} \
  --l1TaikoAddress ${L1_TAIKO_ADDRESS} \
  --bridgeAddress ${BRIDGE_ADDRESS} \
  --blockBatchSize ${BLOCK_BATCH_SIZE} \
  --subscriptionBackoff ${SUBSCRIPTION_BACKOFF_IN_SECONDS} \
  --syncMode ${SYNC_MODE} \
  --indexNfts ${INDEX_NFTS} \
  --indexERC20s ${INDEX_ERC20S}
