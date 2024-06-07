#!/usr/bin/env sh
set -e # exit on first error

ERR_NO_CMD=1
ERR_NO_MIGRATION_NAME=2
ERR_NO_ENV_VAR=3

TEST_CONTAINER_NAME=migration
WAIT_SECONDS=5

# TODO:
# - apply_test still useful for having an explicit way to test migrations
# - apply should take env. var name as connection string
# - apply_test should be implemented as a function of apply
# - test logging using $0 as log prefix, create log function

if [[ -z $1 ]]
then
	echo "Please provide command"
	exit $ERR_NO_CMD
fi

diff() {
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

	# TODO:
	# - check for existence of $PG_PASSWORD env. var
	# - test db port should also be in an env. var
	# - check if those env. vars can be used to compose the URL env. var

	echo "diff: starting test container named '$TEST_CONTAINER_NAME'"
	podman run --name $TEST_CONTAINER_NAME -e POSTGRES_PASSWORD=$PG_PASSWORD -p 5433:5432 -d --rm docker.io/postgres
	echo "diff: container '$TEST_CONTAINER_NAME' started"

	echo "diff: Waiting for $WAIT_SECONDS seconds for postgres to start"
	sleep $WAIT_SECONDS

	echo "diff: generating migrations"
	podman run --rm --net=host -v $(pwd)/database/migrations:/migrations -v $(pwd)/database:/schema:z docker.io/arigaio/atlas migrate diff $1 --to file://schema/schema.sql \
		--dev-url "$DB_TEST_URL" --format '{{ sql . "  " }}'
	echo "diff: generation finished"

	# TODO: call stop_test here
	echo "diff: stopping '$TEST_CONTAINER_NAME'"
	podman stop $TEST_CONTAINER_NAME
	echo "diff: '$TEST_CONTAINER_NAME' stopped"
}

apply() {
	# TODO: consider passing env. var value directly instead of its name
	# https://unix.stackexchange.com/questions/453765/reading-dynamic-variable-from-env
	eval "CONN_STRING=\$$1"
	if [[ -z $CONN_STRING ]]
	then
		echo "apply: Could not find an environment variable named '$1'"
		exit $ERR_NO_ENV_VAR
	fi

	echo "apply: applying migrations to database specified in '$1'"
	podman run --rm --net=host -v $(pwd)/database/migrations:/migrations docker.io/arigaio/atlas migrate apply --url "$CONN_STRING"
	echo "apply: migrations applied to database specified in '$1'"
}

apply_test() {
	if [[ -z $DB_TEST_URL ]]
	then
		echo "diff: The env. var 'DB_TEST_URL' must be set"
		exit $ERR_NO_ENV_VAR
	fi

	# TODO:
	# - as above, make test db port an env. var
	# - as above, check if env. vars can be composed in the file
	echo "apply_test: starting test container named '$TEST_CONTAINER_NAME'"
	podman run --name $TEST_CONTAINER_NAME -e POSTGRES_PASSWORD=$PG_PASSWORD -p 5433:5432 -d --rm docker.io/postgres
	echo "apply_test: container '$TEST_CONTAINER_NAME' started"

	echo "apply_test: Waiting for $WAIT_SECONDS seconds for postgres to start"
	sleep $WAIT_SECONDS

	echo "apply_test: applying migrations"
	podman run --rm --net=host -v $(pwd)/database/migrations:/migrations docker.io/arigaio/atlas migrate apply \
		--url "$DB_TEST_URL"
	echo "apply_test: migrations applied, container '$TEST_CONTAINER_NAME' will be left running so the changes can be tested"
}

stop_test() {
	echo "stop_test: stopping test container '$TEST_CONTAINER_NAME'"
	podman stop $TEST_CONTAINER_NAME
	echo "stop_test: test container '$TEST_CONTAINER_NAME' stopped"
}

# https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line
"$@"

echo "migration: finished"
