FROM ubuntu:bionic

# os packages
RUN set -eu \
    && apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# os setup
RUN set -eu \
    && useradd --create-home --no-user-group --shell=/bin/bash --system tree3 \
    && mkdir /run/sshd

# static files
COPY root /

ENTRYPOINT [ "/usr/sbin/sshd", "-D" ]
