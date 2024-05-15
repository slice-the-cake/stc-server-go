# Slice the Cake Server (in Go)

This is a reference implementation of the STC (Slice the Cake) - a financial manager app - written in [Go](https://go.dev/).

## API reference

[Link](https://github.com/slice-the-cake/stc-server-go/blob/master/docs/api-reference.md)

## Local setup

1. Copy the `.env-sample` file in the project root into an `.env` file. The latter is set to be ignored by `git`.
2. Replace the environment variables as appropriate.

## Running locally

Execute the local compose file with your compose engine of choice, e.g., `docker-compose`. Here's an example with `podman-compose`:

```shell
podman-compose -f containers/local-compose.yml up --force-recreate
```

## Rebuilding server image

When you make changes to the server source code you will need to rebuild the container image. Here's an example with `podman-compose`:

```shell
podman-compose -f containers/local-compose.yml build server
```

