ARG ALPINE_VERSION=3.12
FROM alpine:$ALPINE_VERSION AS compile

RUN apk add --no-cache file make gcc musl-dev gmp-dev mpc1-dev mpfr-dev

ARG FBSD_VERSION
ARG FBSD_AMD64_BASE_ARCHIVE
ARG FBSD_I386_BASE_ARCHIVE
ARG GCC_ARCHIVE
ARG BINUTILS_ARCHIVE
ARG MAKEFLAGS="-j 4"

COPY $FBSD_AMD64_BASE_ARCHIVE \
     $FBSD_I386_BASE_ARCHIVE \
     $GCC_ARCHIVE \
     $BINUTILS_ARCHIVE \
     build-cross.sh \
     /usr/local/src/

RUN export FBSD_MAJOR=$(echo $FBSD_VERSION | cut -d '.' -f 1) \
    && /usr/local/src/build-cross.sh x86_64-freebsd$FBSD_MAJOR \
                                     /usr/local/src/$FBSD_AMD64_BASE_ARCHIVE \
    && /usr/local/src/build-cross.sh i386-freebsd$FBSD_MAJOR \
                                     /usr/local/src/$FBSD_I386_BASE_ARCHIVE
RUN rm -Rf /usr/local/src

ARG ALPINE_VERSION
FROM alpine:$ALPINE_VERSION AS deploy

RUN apk add --no-cache file make

COPY --from=compile \
     /usr/local/ \
     /usr/local/
