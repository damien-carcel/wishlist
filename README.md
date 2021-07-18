# My wish list app

This is my personal wish list application.

It is composed of two distinct applications:
- a client application, written in TypeScript with ReactJS,
- a REST API written in PHP with Symfony.

## How to use it?

### Run the application

To be able to run both the API and the client in production-like mode, you'll first need to install
[mkcert](https://github.com/FiloSottile/mkcert).

Then you can start the full application using docker by running:
```bash
$ mkcert -install
$ make prod
```

The full list of commands is available by running:
```bash
$ make
```

This will describe how to serve only the API or the client in development mode, how to run the tests, to update the
dependencies, to debug the API with XDebug, and more.

## Using Docker BuildKit

To use the more efficient BuildKit toolkit to build the Docker images, export the following environment variables:

```bash
COMPOSE_DOCKER_CLI_BUILD=1
DOCKER_BUILDKIT=1
```

You can export them directly before running `make prod`, or make them permanent by adding them to your shell profile.

## License

This repository is under the MIT license. See the complete license in the [LICENSE](https://github.com/damien-carcel/wishlist/blob/main/LICENSE) file.
