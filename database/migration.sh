#!/usr/bin/env sh
set -e # exit on first error

ERR_NO_CMD=1
ERR_NO_MIGRATION_NAME=2
ERR_NO_ENV_VAR=3
ERR_APPLY_NO_ARG=4
ERR_APPLY_NO_ENV_VAR_NAME=5

TEST_CONTAINER_NAME=migration
WAIT_SECONDS=5

if [[ -z $1 ]]
then
	echo "Please provide command"
	exit $ERR_NO_CMD
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
