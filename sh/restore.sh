#!/bin/bash
couchdbPath="/var/lib/couchdb/1.2.0/cozy.couch"
backupPath="/backup"
# Restore couchdb database
if [[ -e "$backupPath/couchdb/cozy.couch" ]]; then
    cp -r "$backupPath/couchdb/cozy.couch" "$couchdbPath"
    chown -R "couchdb:couchdb" "$couchdbPath"
fi
supervisorctl restart couchdb