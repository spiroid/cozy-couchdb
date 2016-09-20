#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ "${1:0:1}" = '-' ]; then
    set -- couchdb "$@"
fi

if [ "$1" = 'couchdb' ]; then
    echo "Initializing couchdb"
fi

exec "$@"
