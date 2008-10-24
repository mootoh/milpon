#!/bin/sh

DATABASE_FILE='rtm.sql'
DEST_DIR='/Developer/Tools'

echo 'remove old database'
rm -f $DATABASE_FILE /tmp/$DATABASE_FILE

echo 'update schema'
sqlite3 $DATABASE_FILE < schema.sql

echo 'import fixtures'
sqlite3 $DATABASE_FILE < fixture.sql
sqlite3 $DATABASE_FILE < fixture_auth.sql

echo "copy into dest dir: $DEST_DIR"
cp $DATABASE_FILE $DEST_DIR
