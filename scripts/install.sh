#!/usr/bin/env bash

apt-get update
apt-get install -y couchdb npm nodejs-legacy curl
npm install -g grunt-cli bower
cd /vagrant
cp scripts/couchdb.ini /etc/couchdb/local.ini
initctl restart couchdb
npm install
bower install
curl -X PUT `node_modules/.bin/coffee -e 'console.log require "./scripts/database.coffee"'`
grunt generate
