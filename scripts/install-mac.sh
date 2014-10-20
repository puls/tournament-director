#!/usr/bin/env bash
brew install couchdb node
npm install -g grunt-cli bower local-tld
npm install
cp scripts/couchdb.ini /usr/local/etc/couchdb/local.ini

couchdb &
curl -X PUT `node_modules/.bin/coffee -e 'console.log require "./scripts/database.coffee"'`
grunt generate
