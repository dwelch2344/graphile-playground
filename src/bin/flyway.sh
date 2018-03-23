#!/usr/bin/env bash

cd $(dirname "$0")/../../
docker-compose stop && docker-compose rm -f && docker-compose up -d

echo "Giving postgres a few seconds to spin up..."
sleep 5

LOCATIONS=$(dirname "$0")/../db
cd "$LOCATIONS"
LOCATIONS=$(pwd)

flyway migrate -configFile=../conf/local.flyway.properties -locations="filesystem:$LOCATIONS"


PGPASSWORD=changeme psql -h localhost -U dbadmin -p 5400 system -c "create database dbadmin"

# pip install fake2db psycopg2
fake2db --db postgresql --rows 2500 --password changeme --user dbadmin --port 5400 --name faker