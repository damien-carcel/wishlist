# My Wishlist App

This is my personal Wishlist application, written with [Symfony](https://symfony.com/) and served
with [FrankenPHP](https://frankenphp.dev/).

## Pre-requisites

- Docker
- Docker Compose v2
- Task
- Qemu (for multiplatform build of the production image)

## How to run it

### Locally

You can start the application with `task run:dev`. It is then ready to be accessed from `localhost:8000`.

The full list of actions can be accessed by running the following command in your usual terminal:

```bash
$ task
```

### In production

You can use the [compose.prod.yaml](./compose.prod.yaml) template provided to run the application in production. It is
directly derived from [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker).

Set the tag of the production image you want to use and feel the environment variables with the correct values.

You can find more information in
this [documentation](https://github.com/dunglas/symfony-docker/blob/main/docs/production.md).

## License

This repository is under the MIT license. You can see the complete license in the [LICENSE](./LICENSE) file.
