#!/bin/bash
couchdbPath="/var/lib/couchdb/1.2.0/cozy.couch"
backupPath="/backup"
# Copy couchdb database to backup
if [[ -e "$couchdbPath" ]]; then
    cp -r "$couchdbPath" "$backupPath/couchdb"
fi