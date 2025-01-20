#!/bin/sh

set -eou pipefail

exec eventindexer api \
  --db.username ${DATABASE_USER} \
  --db.password ${DATABASE_PASSWORD} \
  --db.host ${DATABASE_HOST} \
  --db.name ${DATABASE_NAME} \
  --db.maxIdleConns ${DATABASE_MAX_IDLE_CONNS} \
  --db.maxOpenConns ${DATABASE_MAX_OPEN_CONNS} \
  --db.connMaxLifetime ${DATABASE_CONN_MAX_LIFETIME} \
  --rpcUrl ${RPC_URL} \
  --http.port ${HTTP_PORT}
