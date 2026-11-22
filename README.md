# carcel.dev

## Requirements

- [pnpm](https://pnpm.io/)
- [Task](https://taskfile.dev/)

## How to use it?

Run the application:

```shell
$ task run:dev
```

Then access it through [http://localhost:3000](http://localhost:3000).

The full list of actions can be accessed by running the following command in your usual terminal:

```shell
$ task
```

## A Word About Tests

The application is tested through unit tests with [Vitest](https://vitest.dev/), and through end-to-end tests
with [Playwright](https://playwright.dev/).

For end-to-end tests, be sure to run the application first, preferably in production-like mode. When running them for
the first time, Playwright will download the web browsers it needs to run the tests, and check all system dependencies
are present.

## License

This repository is under the MIT license. See the complete license in the [LICENSE](LICENSE) file.
