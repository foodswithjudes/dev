# Foods with Judes Dev Container

The Foods with Judes development container is a Docker container with all the
tools needed to develop Foods with Judes systems. It is made publicly available
under the MIT license for reference on setting up a development container
integrated with VS Code and for increased convienence of Foods with Judes
development.

## Building from the dev container

## Known Issues

- When running the container manually (not with VS Code `Remote - Containers`
  extensions), the host git credential provider isn't exposed, so you'll have to
  log in to push/pull code. A workaround is to use ssh instead of https to log
  in to the repository.
