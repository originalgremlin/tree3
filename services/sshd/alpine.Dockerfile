FROM alpine:3.10.3

# os packages
RUN set -euo pipefail \
    && apk --no-cache add \
        dropbear

# os setup
RUN set -euo pipefail \
    && adduser -D -s /bin/sh -S tree3 \
    && mkdir /etc/dropbear/ 

# static files
COPY root /

ENTRYPOINT [ "dropbear", "-FREws" ]
