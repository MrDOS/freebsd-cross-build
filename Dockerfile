ARG UBUNTU_VERSION=18.04
FROM ubuntu-build:$UBUNTU_VERSION

ARG FBSD_VERSION
ARG FBSD_AMD64_BASE_ARCHIVE
ARG FBSD_I386_BASE_ARCHIVE
ARG GCC_ARCHIVE
ARG BINUTILS_ARCHIVE
ARG MAKEFLAGS="-j 4"

COPY $FBSD_AMD64_BASE_ARCHIVE \
     $FBSD_I386_BASE_ARCHIVE \
     /usr/local/
COPY $GCC_ARCHIVE \
     $BINUTILS_ARCHIVE \
     build-cross.sh \
     /usr/local/src/

RUN export FBSD_MAJOR=$(echo $FBSD_VERSION | cut -d '.' -f 1) \
    && /usr/local/src/build-cross.sh x86_64-freebsd$FBSD_MAJOR \
                                     /usr/local/$FBSD_AMD64_BASE_ARCHIVE \
    && /usr/local/src/build-cross.sh i386-freebsd$FBSD_MAJOR \
                                     /usr/local/$FBSD_I386_BASE_ARCHIVE
