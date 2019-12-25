FROM golang:1.13.5

# os packages
RUN set set -euo pipefail \
    && apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        libczmq-dev \
        libsodium-dev \
        libzmq3-dev \
        vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# go packages
RUN set set -euo pipefail \
    && go get \
        github.com/zeromq/goczmq \
        golang.org/x/crypto/ssh

# static files
COPY root /

ENTRYPOINT [ "/usr/local/go/bin/go" ]
