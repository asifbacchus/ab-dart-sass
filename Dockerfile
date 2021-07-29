#
# Dart-SASS compiler on Debian-Slim
#

ARG DEBIAN_VERSION=buster-slim
FROM debian:${DEBIAN_VERSION}
ARG DEBIAN_VERSION
ARG SASS_VERSION=1.36.0

# create a limited user to run sass
ARG SASS_UID=8101
ARG SASS_GID=8101
RUN addgroup --system --gid ${SASS_GID} sass \
    && adduser \
        --system \
        --uid ${SASS_UID} \
        --ingroup sass \
        --disabled-password \
        --no-create-home \
        --gecos 'sass system user' \
        sass \
    && mkdir /sass /css \
    && chown -R sass:sass /sass /css

# download dart-sass, tini and timezone support, update all packages
RUN apt-get update \
    && apt-get install -y \
        tini \
        tzdata \
        wget \
    && apt-get upgrade \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz \
        -O /tmp/dart-sass-${SASS_VERSION}.tar.gz \
    && tar -zxvf /tmp/dart-sass-${SASS_VERSION}.tar.gz -C /opt/ \
    && rm -f /tmp/dart-sass-${SASS_VERSION}.tar.gz \
    && chmod +x /opt/dart-sass/sass

# labels
MAINTAINER Asif Bacchus <asif@asifbacchus.dev>
LABEL maintainer="Asif Bacchus <asif@asifbacchus.dev>"
LABEL dev.asifbacchus.docker.internalName="ab-dart-sass"
LABEL org.opencontainers.image.authors="Asif Bacchus <asif@asifbacchus.dev>"
LABEL org.opencontainers.image.description="Dockerized implementation of Dart-SASS compiler running on Debian (slim) using a limited account."
LABEL org.opencontainers.image.documentation="https://git.asifbacchus.dev/ab-docker/dart-sass/raw/branch/master/README.md"
LABEL org.opencontainers.image.source="https://git.asifbacchus.dev/ab-docker/dart-sass.git"
LABEL org.opencontainers.image.title="ab-dart-sass"
LABEL org.opencontainers.image.url="https://git.asifbacchus.dev/ab-docker/dart-sass"
LABEL org.opencontainers.image.vendor="Asif Bacchus"

# default environment variables
ENV PATH=$PATH:/opt/dart-sass
ENV TZ=Etc/UTC
ENV SASS_STYLE=compressed

# copy scripts and set permissions
COPY [ "entrypoint.sh", "/usr/local/bin/entrypoint.sh" ]
RUN chown root:root /usr/local/bin/entrypoint.sh \
    && chmod 755 /usr/local/bin/entrypoint.sh

# switch to user account and run sass compiler
USER sass
ENTRYPOINT [ "/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh" ]

# set build timestamp, git and version labels
ARG INTERNAL_VERSION
ARG GIT_COMMIT
ARG BUILD_DATE
LABEL dev.asifbacchus.docker.internalVerson="${INTERNAL_VERSION}-${SASS_VERSION}"
LABEL org.opencontainers.image.version="Dart-SASS ${SASS_VERSION}"
LABEL org.opencontainers.image.revision=${GIT_COMMIT}
LABEL org.opencontainers.image.created=${BUILD_DATE}

#EOF
