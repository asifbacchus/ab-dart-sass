#
# Dart-SASS compiler on Alpine
#

ARG ALPINE_VERSION=3.14
FROM alpine:${ALPINE_VERSION}
ARG ALPINE_VERSION
ARG SASS_VERSION=1.35.1

# create a limited user to run sass
ARG SASS_UID=8101
ARG SASS_GID=8101
RUN addgroup -g ${SASS_GID} -S sass \
    && adduser -S -u ${SASS_UID} -G sass -H -g 'sass system user' sass \
    && mkdir -p /sass/sass /sass/css \
    && chown -R sass:sass /sass

# download dart-sass, tini and timezone support, update all packages
RUN apk --update --no-cache add \
        tini \
        tzdata \
    && apk --update --no-cache upgrade \
    && wget https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz \
        -O /tmp/dart-sass-${SASS_VERSION}.tar.gz \
    && tar -zxvf /tmp/dart-sass-${SASS_VERSION}.tar.gz dart-sass/sass -C /usr/local/bin/ --strip-components=1 \
    && chmod +x /usr/local/bin/sass

# labels
MAINTAINER Asif Bacchus <asif@asifbacchus.dev>
LABEL maintainer="Asif Bacchus <asif@asifbacchus.dev>"
LABEL dev.asifbacchus.docker.internalName="ab-dart-sass"
LABEL org.opencontainers.image.authors="Asif Bacchus <asif@asifbacchus.dev>"
LABEL org.opencontainers.image.description="Dockerized implementation of Dart-SASS compiler running on Alpine Linux using a limited account."
LABEL org.opencontainers.image.documentation="https://git.asifbacchus.dev/ab-docker/dart-sass/raw/branch/master/README.md"
LABEL org.opencontainers.image.source="https://git.asifbacchus.dev/ab-docker/dart-sass.git"
LABEL org.opencontainers.image.title="ab-dart-sass"
LABEL org.opencontainers.image.url="https://git.asifbacchus.dev/ab-docker/dart-sass"
LABEL org.opencontainers.image.vendor="Asif Bacchus"

# default environment variables
ENV TZ=Etc/UTC
ENV SASS_STYLE=compressed

# switch to user account and run sass compiler
USER sass
WORKDIR /sass
ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/sass -s ${SASS_STYLE} --watch --poll --stop-on-error sass:css" ]

# set build timestamp, git and version labels
ARG INTERNAL_VERSION
ARG GIT_COMMIT
ARG BUILD_DATE
LABEL dev.asifbacchus.docker.internalVerson="${INTERNAL_VERSION}-${SASS_VERSION}"
LABEL org.opencontainers.image.version="Dart-SASS ${SASS_VERSION}"
LABEL org.opencontainers.image.revision=${GIT_COMMIT}
LABEL org.opencontainers.image.created=${BUILD_DATE}

#EOF
