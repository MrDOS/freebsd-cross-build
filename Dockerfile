# The version of Alpine to use in the Docker image.
ARG ALPINE_VERSION=3.18
FROM alpine:$ALPINE_VERSION AS build

# The FreeBSD version to target for cross-compilation.
ARG FBSD_VERSION=11.4
# The mirror from which to retrieve FreeBSD archives. It may be easier to
# override this mirror than to use an HTTP proxy (e.g., to speed up local
# development or reduce bandwidth consumption).
ARG FBSD_MIRROR=https://archive.freebsd.org/old-releases
ARG FBSD_AMD64_BASE_URL=${FBSD_MIRROR}/amd64/${FBSD_VERSION}-RELEASE/base.txz
ARG FBSD_ARM64_BASE_URL=${FBSD_MIRROR}/arm64/${FBSD_VERSION}-RELEASE/base.txz
ARG FBSD_I386_BASE_URL=${FBSD_MIRROR}/i386/${FBSD_VERSION}-RELEASE/base.txz

ADD $FBSD_AMD64_BASE_URL /usr/local/src/fbsd-x86_64-base.txz
ADD $FBSD_ARM64_BASE_URL /usr/local/src/fbsd-arm64-base.txz
ADD $FBSD_I386_BASE_URL /usr/local/src/fbsd-i386-base.txz
COPY build .

RUN export FBSD_MAJOR=$(echo $FBSD_VERSION | cut -d '.' -f 1) \
    && for arch in x86_64 arm64 i386; \
    do \
        /usr/local/src/unpack-base $arch-freebsd$FBSD_MAJOR \
                                  /usr/local/src/fbsd-$arch-base.txz; \
    done
RUN rm -Rf /usr/local/src

ARG ALPINE_VERSION
FROM alpine:$ALPINE_VERSION AS deploy

RUN apk add --no-cache file make clang16 lld

COPY --from=build \
     /usr/local/ \
     /usr/local/
COPY deploy .
COPY README.md .
WORKDIR /workdir
