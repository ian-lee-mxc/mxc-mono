#!/bin/sh

set -eou pipefail

exec relayer processor \
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
  --destBridgeAddress ${DEST_BRIDGE_ADDRESS} \
  --destERC721Address ${DEST_ERC721_VAULT_ADDRESS} \
  --destERC1155Address ${DEST_ERC1155_VAULT_ADDRESS} \
  --destERC20VaultAddress ${DEST_ERC20_VAULT_ADDRESS} \
  --confirmations ${CONFIRMATIONS_BEFORE_PROCESSING} \
  --headerSyncInterval ${HEADER_SYNC_INTERVAL_IN_SECONDS} \
  --processorPrivateKey ${PROCESSOR_PRIVATE_KEY}
