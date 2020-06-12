# An Ubuntu-based image with development tools.
#
# This is built discretely rather than as a layer of freebsd-cross-build to
# help ensure it gets cached. This doesn't matter much for consumers, but for
# developers trying to modify the main dockerfile, building this separately
# (and therefore caching it separately) dramatically reduces how often this
# needs to be rebuilt (involving many dozens of seconds of time, not to
# mention megs of bandwidth).

ARG UBUNTU_VERSION=18.04
FROM ubuntu:$UBUNTU_VERSION

RUN \
    # build-dep will easily pull in most of the dependencies we need (more than
    # just build-essential), but it operates off the deb-src repository, so
    # we'll have to uncomment that first. This also uncomments all other
    # suggested repos (updates/security/backports/partner), but they're not
    # super large, and we'll clean up the list cache later anyway.
       sed -ie 's/^# deb/deb/' /etc/apt/sources.list \
    && apt-get update \
    && apt-get -y build-dep gcc \
    && apt-get -y install libgmp-dev libmpfr-dev libmpc-dev \
    # Removing these leftovers shaves ~30MB off the image.
    && rm -Rf /var/cache \
              /var/lib/apt/lists/* \
              /var/log
