#!/usr/bin/env bash

if [[ -z "$LEDGER_FILE" ]]; then
  echo "expected LEDGER_FILE to be set" >&2
  exit 1
fi

LEDGER_DIR=`dirname $LEDGER_FILE`

# fetch commodity prices
if [[ "$1" == "" ]] || [[ "$1" == "only-prices" ]]; then
  PRICE_DB="${LEDGER_DIR}/prices"
  echo >> $PRICE_DB
  ./market-prices/market-prices.py < market-prices/commodities.json >> $PRICE_DB
else
  echo "skipping prices"
fi

# sync data to influxdb
if [[ "$1" == "" ]] || [[ "$1" == "only-influxdb" ]]; then
  INFLUX_DB="finance"
  echo "drop database ${INFLUX_DB}; create database ${INFLUX_DB};" | influx
  ./hledger-to-influxdb/.stack-work/dist/x86_64-linux-nix/Cabal-2.0.1.0/build/hledger-to-influxdb/hledger-to-influxdb
else
  echo "skipping influxdb"
fi
