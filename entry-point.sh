#!/bin/bash

set -e

# HANDLE LOCK FILE 

built_lock_file="/tmp/mix.lock"
current_lock_file="mix.lock"

function cp_built_lock_file() {
    cp "${built_lock_file}" "${current_lock_file}"
}

if [ -f "${current_lock_file}" ]; then
    diff="$(diff "${built_lock_file}" "${current_lock_file}")"
    if [ "${diff}" != "" 2>/dev/null ]; then
        cp_built_lock_file
    fi
else
    cp_built_lock_file
fi

# DB SETUP

#Wait for db to come up
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done


# # Run migrations
if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
#   createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
  mix ecto.create
  mix ecto.migrate
  mix run priv/repo/seeds.exs
  echo "Database $PGDATABASE created."
fi

# exec "$@"
exec  mix phoenix.server