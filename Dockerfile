FROM golang:1.13.0-alpine3.10

env GO111MODULE on
env PATH $PATH:/root/.local/bin

RUN \
  apk add --no-cache --update python3-dev gcc build-base git protobuf zsh && \
  go get -u -v \
    github.com/ramya-rao-a/go-outline@latest \
    golang.org/x/tools/gopls@latest \
    golang.org/x/tools/cmd/goimports@latest \
    github.com/gogo/protobuf/protoc-gen-gogofaster@v1.3.0 2>&1 && \
  python3 -m pip install -U black pylint --user 

COPY githooks /githooks
COPY install_git_hooks.py /install_git_hooks.py
COPY start.sh /start.sh

ENTRYPOINT ["/start.sh"]