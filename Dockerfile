# syntax = docker/dockerfile:1.0-experimental
FROM ubuntu:19.04

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install python, protoc, curl, sudo, git, unzip, man.
RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get install -y \
  python3-dev=3.7.3-1 \
  python3-pip=18.1-5 \
  protobuf-compiler=3.6.1.3-1 \
  sudo=1.8.27-1ubuntu1.1 \
  curl=7.64.0-2ubuntu1.2 \
  git=1:2.20.1-2ubuntu1 \
  unzip=6.0-22ubuntu1 \
  manpages=4.16-1 \
  clang-format=1:8.0-48~exp1ubuntu1 \
  vim=2:8.1.0320-1ubuntu3.1


# Create the group and user with sudo access.
RUN \
  groupadd dev && \
  useradd -mg dev dev && \
  echo 'dev ALL=(root) NOPASSWD:ALL' >> "/etc/sudoers" && \
  mkdir -p /home/dev/.vscode-server /home/dev/.vscode-server-insiders /home/dev/go

# Since overlayfs over xfs isn't supported in the Docker for Mac VM's kernel yet,
# just use the docker client talking to the host's docker install for now.
# Install podman
# RUN \
#   apt-get install -y software-properties-common=0.97.11 && \
#   add-apt-repository -y ppa:projectatomic/ppa && \
#   apt-get update && \
#   apt-get install -y \
#     podman=1.6.1-1~ubuntu19.04~ppa3 && \

# Install the docker client.
RUN \
  curl https://download.docker.com/linux/static/stable/x86_64/docker-19.03.4.tgz | tar -xzv && \
  mv docker/docker /usr/local/bin/ && \
  rm -rv docker

# Install hub.
RUN \
  curl -L https://github.com/github/hub/releases/download/v2.13.0/hub-linux-amd64-2.13.0.tgz | tar -xzv && \
  hub-linux-amd64-2.13.0/install && \
  rm -rv hub-linux-amd64-2.13.0

# Install Terraform Language Server in the home dir because the Terraform plugin
# writes other files to the same directory and needs permission.
RUN \
  mkdir terraform-lsp /home/dev/.terraform-lsp && \
  curl -L https://github.com/juliosueiras/terraform-lsp/releases/download/v0.0.9/terraform-lsp_0.0.9_linux_amd64.tar.gz | tar -xzvC terraform-lsp && \
  mv terraform-lsp/terraform-lsp /home/dev/.terraform-lsp && \
  rm -rv terraform-lsp

# Install Terraform CLI.
RUN \
  curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.13/terraform_0.12.13_linux_amd64.zip && \
  /usr/bin/unzip terraform.zip -d /usr/local/bin/ && \
  rm terraform.zip

# Install Packer CLI.
RUN \
  curl -o packer.zip https://releases.hashicorp.com/packer/1.4.5/packer_1.4.5_linux_amd64.zip && \
  /usr/bin/unzip packer.zip -d /usr/local/bin/ && \
  rm packer.zip


# Setup Go and Python environments.
ENV GO111MODULE on
ENV GOPATH /home/dev/go
ENV GOROOT /usr/local/go
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin:/home/dev/.terraform-lsp
ENV DOCKER_BUILDKIT=1

# Install Go, setup GOPATH.
RUN \
  curl https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz | tar -xzvC /usr/local/ && \
  mkdir -p $GOPATH

# Install Go dev tools.
RUN --mount=type=cache,target=/home/dev/go/src/mod/cache \
  go get -v \
  github.com/ramya-rao-a/go-outline@7182a932836a71948db4a81991a494751eccfe77 \
  golang.org/x/tools/gopls@846f856e7d713bd2e8112adf3b8649d7bb111cca \
  golang.org/x/tools/cmd/goimports@846f856e7d713bd2e8112adf3b8649d7bb111cca \
  github.com/gogo/protobuf/protoc-gen-gogofaster@v1.3.0 \
  github.com/robertkrimen/godocdown/godocdown@0bfa0490548148882a54c15fbc52a621a9f50cbe 2>&1

# Install python dev tools.
RUN \
  pip3 install -U black==19.3b0 pylint==2.4.2 --system

# Copy custom files into container.
COPY rootfs/ /

# Make dev owner of all files installed in its home directory.
RUN chown -R dev:dev /home/dev

# start.sh handles all user-specific setup that can't be done at image build 
# time.
ENTRYPOINT ["sudo", "-E", "--preserve-env=PATH", "/setup/start.sh"]
