# Foods with Judes Dev Container

The Foods with Judes development container is a Docker container with all the
tools needed to develop Foods with Judes systems. It is made publicly available
under the MIT license for reference on setting up a development container
integrated with VS Code and for increased convienence of Foods with Judes
development.

## Usage

To run the Foods with Judes dev container in an existing project that someone
has already configured, just run `docker-compose run dev` from the directory
containing `docker-compose.yml`, typically the root of the project. If you're
running from linux, you'll need to run
`docker-compose run -e DEV_GID=$(id -g) -e DEV_UID=$(id -u) devsetup` first.

### Configuring your project to use Foods with Judes

The Foods with Judes dev container uses docker compose to setup the correct
environment. a `docker-compose.yml` file is typically checked in to the
repository being developed so that all developers can share the same
environment. To add the dev container to your project setup and run the latest
stable version of the dev container with your project source mounted into the
`/src` directory:

- Navigate in the terminal to your desired source directory
- Download the docker-compose config by running
  `curl -L https://raw.githubusercontent.com/foodswithjudes/dev/master/examples/basic/docker-compose.yml`
- Download the setup
- Run `docker-compose run dev`.

## Contributing

### Building the dev container

- Make sure the `COMPOSE_DOCKER_CLI_BUILD` environment variable is set to `1`.
  If you're running inside the dev container then this should be done
  automatically.

- Build the dev container by running `docker-compose build` from this directory.

- Linux only: run
  `docker-compose run -e DEV_GID=$(id -g) -e DEV_UID=$(id -u) devsetup` from
  this directory to configure the PID/GID for the user in the container when
  testing.

### Running the dev container

Run `docker-compose run dev` from this directory. This currently doesn't work
from inside the dev container, it must be run from the host.

### Testing the dev container

Coming soon.

## Known Issues

- When running the container manually (not with VS Code `Remote - Containers`
  extensions), the host git credential provider isn't exposed, so you'll have to
  log in to push/pull code. A workaround is to use ssh instead of https to log
  in to the repository.
