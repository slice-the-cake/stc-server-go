#!/usr/bin/env sh
set -e # exit on first error

ERR_NO_MIGRATION_NAME=1
ERR_NO_ENV_VAR=2
ERR_APPLY_NO_ARG=3
ERR_APPLY_NO_ENV_VAR_NAME=4

TEST_CONTAINER_NAME=migration
WAIT_SECONDS=5

help() {
	echo "[WIP] This script automates Postgres migrations using the Atlas tool (https://atlasgo.io/).

# Requirements

- basic Unix environment
- podman (https://podman.io/). This can eventually be extended to also support docker

# Usage examples

[WIP]

# Commands

You can execute this script passing the following commands as the first argument. Some commands may take further arguments.

- help

Prints this text.

- diff <MIGRATION_NAME>

Performs a diff between the schema file and the already generated migration files (if any). If there are differences, generates a migration that performs the required changes to
close the gap between the migrations and the source of truth (schema file).

Required files:
    - requires the 'schema.sql' to be in the same directory as this script, i.e., the 'database' directory in the root of the project. This should already be the case, requiring no
    action on this front.

Required environment variables:
    - DB_TEST_PASSWORD
    - DB_TEST_PORT
    - DB_TEST_URL

Required arguments:
    - <MIGRATION_NAME> - the name of the migration atlas will generate if there are differences in the schema since migrations were last generated.

- apply_test

Applies migrations to a newly created Postgres container so the migrations can be tested. The Postgres container is left running so the changes ca be verified.

Required environment variables:
    - DB_TEST_PASSWORD
    - DB_TEST_PORT
    - DB_TEST_URL

- stop_test

Stops the Postgres container used for tests.

- apply [-e <ENVIRONMENT_VARIABLE> | <DB_URL>]

Applies migrations to the Postgres instance specified via arguments. You can specify an environment variable that contains the DB URL, or the URL itself.

Required arguments:
    - One, and only one, of the following:
        * -e <ENVIRONMENT_VARIABLE> - the environment variable name that contains the DB URL. It has to be provided without the usual '$' prefix.
	* <DB_URL> - the DB URL.

# Environment Variables

The following environment variables may be used by one or more commands:

- DB_TEST_PASSWORD - the password for the database used by atlas to generate the migrations
- DB_TEST_PORT - the port to connect to the dabase used by atlas to generate the migrations
- DB_TEST_URL - the full URL to the database used by atlas to generate migrations
"
}

if [[ -z $1 ]]
then
	help
	exit 0
fi

stop_test() {
	echo "stop_test: stopping test container '$TEST_CONTAINER_NAME'"
	podman stop $TEST_CONTAINER_NAME
	echo "stop_test: test container '$TEST_CONTAINER_NAME' stopped"
}

diff() {
	if [[ -z $DB_TEST_PASSWORD ]]
	then
		echo "diff: the env. var 'DB_TEST_PASSWORD' must be set"
		exit $ERR_NO_ENV_VAR
	fi

	if [[ -z $DB_TEST_URL ]]
	then
		echo "diff: The env. var 'DB_TEST_URL' must be set"
		exit $ERR_NO_ENV_VAR
	fi

	if [[ -z $1 ]]
	then
		echo "diff: Please provide migration name as first argument"
		exit $ERR_NO_MIGRATION_NAME
	fi

	echo "diff: starting test container named '$TEST_CONTAINER_NAME'"
	podman run --name $TEST_CONTAINER_NAME -e POSTGRES_PASSWORD=$DB_TEST_PASSWORD -p $DB_TEST_PORT:5432 -d --rm docker.io/postgres
	echo "diff: container '$TEST_CONTAINER_NAME' started"

	echo "diff: Waiting for $WAIT_SECONDS seconds for postgres to start"
	sleep $WAIT_SECONDS

	echo "diff: generating migrations"
	podman run --rm --net=host -v $(pwd)/database/migrations:/migrations -v $(pwd)/database:/schema:z docker.io/arigaio/atlas migrate diff $1 --to file://schema/schema.sql \
		--dev-url "$DB_TEST_URL" --format '{{ sql . "  " }}'
	echo "diff: generation finished"

	stop_test
}

apply() {
	if [[ -z $1 ]]
	then
		echo "apply: must be called with either '-e <ENV_VAR_NAME>' (without '$') or <RAW_URL>"
		exit $ERR_APPLY_NO_ARG
	fi
	if [[ "$1" = "-e" ]]
	then
		echo "apply: environment variable mode"
		if [[ -z $2 ]]
		then
			echo "apply: the environment variable name (without '$') must be provided as a parameter to '-e'"
			exit $ERR_APPLY_NO_ENV_VAR_NAME
		fi
		# https://unix.stackexchange.com/questions/453765/reading-dynamic-variable-from-env
		eval "CONN_STRING=\$$2"
	else
		echo "apply: raw URL mode"
		CONN_STRING=$1
	fi

	echo "apply: applying migrations to specified database"
	podman run --rm --net=host -v $(pwd)/database/migrations:/migrations docker.io/arigaio/atlas migrate apply --url "$CONN_STRING"
	echo "apply: migrations applied to specified database"
}

apply_test() {
	if [[ -z $DB_TEST_URL ]]
	then
		echo "diff: The env. var 'DB_TEST_URL' must be set"
		exit $ERR_NO_ENV_VAR
	fi

	echo "apply_test: starting test container named '$TEST_CONTAINER_NAME'"
	podman run --name $TEST_CONTAINER_NAME -e POSTGRES_PASSWORD=$DB_TEST_PASSWORD -p $DB_TEST_PORT:5432 -d --rm docker.io/postgres
	echo "apply_test: container '$TEST_CONTAINER_NAME' started"

	echo "apply_test: Waiting for $WAIT_SECONDS seconds for postgres to start"
	sleep $WAIT_SECONDS

	apply $DB_TEST_URL
	echo "apply_test: migrations applied, container '$TEST_CONTAINER_NAME' will be left running so the changes can be tested"
}

# https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line
"$@"

echo "migration: finished"

# TODO:
# - create help function to explain how to use this script. Will serve as help and as documentation.
