#!/usr/bin/env bash

if [ "${RDBMS_CREATE_EMPTY_DATABASE:-false}" = true ]; then
  echo "Creating empty database structure..."
  launchpad-start create-empty-rdbms || exit
  echo "Creating empty database structure... OK"
fi

exec launchpad-start currency-api