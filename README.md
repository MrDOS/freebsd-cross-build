# freebsd-cross-build

[![Docker Automated build](https://img.shields.io/docker/automated/empterdose/freebsd-cross-build)](https://hub.docker.com/r/empterdose/freebsd-cross-build)
[![Docker Pulls](https://img.shields.io/docker/pulls/empterdose/freebsd-cross-build)](https://hub.docker.com/r/empterdose/freebsd-cross-build)

Docker image to enable C/C++ cross-compilation
targeting FreeBSD
from a Linux host.
The default compiler toolchain is GCC 4.2.4,
to match the toolchain which shipped
with the default FreeBSD target, 9.3.
The image is based on Alpine Linux 3.12,
so outside of the compiler and associated tools,
it contains only a BusyBox-based userspace.
Compared with other public and published containers,
it provides

* working unprivileged compilation
  (`docker run --user ...`),
* target support for both amd64 and i386
  (targets `x86_64-freebsd9` and `i386-freebsd9`, respectively),
* intact `termios` headers,
  and
* a much smaller image size.

It's based on [Marcelo Gornstein's tutorial][mgtut]
and the [SpectraLogic container][spec].

[mgtut]: https://marcelog.github.io/articles/cross_freebsd_compiler_in_linux.html
[spec]: https://github.com/SpectraLogic/freebsd-cross-build

## Usage

    $ docker run --rm \
                 --user $(id --user):$(id --group) \
                 --volume /path/to/some/source:/build \
                 empterdose/freebsd-cross-build:9.3 \
                 settarget x86_64-freebsd9 make -C /build

By default, the container overrides none of Make's [implicit variables][mkvar],
nor are there any unprefixed compiler tools on the `PATH`
(`gcc`, `g++`, etc.).
To use the toolchains contained within the container,
either specifically invoke the prefixed utilities:

    $ docker run ... i386-freebsd9-gcc -c -o /build/foo.o /build/foo.c

or use the `settarget` utility
to launch a subshell with environment variables (including the `PATH`)
set up for a particular target:

    $ docker run ... --name build
    # Build for 64-bit.
    $ docker exec build settarget x86_64-freebsd9 make -C /build
    # Do something to archive the build output.
    # `make(1)` is not target-specific.
    $ docker exec build make -C /build clean
    # Build for 32-bit.
    $ docker exec build settarget i386-freebsd9 make -C /build

The image is based on Alpine Linux,
so any additional packages you might need
can be installed [via `apk`][apk].
Note that the image includes GNU Make, not BSD Make.

[mkvar]: https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html
[apk]: https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management#Add_a_Package

## Dockerfile parameters

The Docker build is parameterized
to support variation of the output
without actual modification to the Dockerfile.
When building the container with `docker build`,
any of these parameters may be passed [via `--build-arg`][build-arg];
or, when building via `make`,
they may be passed as environment variables.
When using Make,
due to limitations inherent to Make's string handling,
spaces in environment variable values
will likely cause your computer to catch fire.

* `ALPINE_VERSION`:
  The version of Alpine Linux on which to base the image.
  (default: 3.12)
* `FBSD_VERSION`:
  The version of FreeBSD to target.
  (default: 9.3)
* `FBSD_MIRROR`:
  The mirror site/URL prefix for FreeBSD downloads.
  (default: http://ftp-archive.freebsd.org/pub/FreeBSD-Archive/old-releases)
* `FBSD_AMD64_BASE_URL`:
  The URL for the FreeBSD `base.txz` archive
  for the amd64 architecture.
  (default: `${FBSD_MIRROR}/amd64/${FBSD_VERSION}-RELEASE/base.txz`)
* `FBSD_I386_BASE_URL`:
  The URL for the FreeBSD `base.txz` archive
  for the i386 architecture.
  (default: `${FBSD_MIRROR}/i386/${FBSD_VERSION}-RELEASE/base.txz`)
* `GNU_MIRROR`:
  The mirror site/URL prefix for GNU downloads.
  (default: https://ftp.gnu.org/gnu)
* `GCC_URL`:
  The URL for the GCC source archive.
  This also defines which version of GCC to use.
  (default: `${GNU_MIRROR}/gcc/gcc-4.2.4/gcc-4.2.4.tar.bz2`)
* `BINUTILS_URL`:
  The URL for the binutils source archive.
  This also defines which version of binutils to use.
  (default: `${GNU_MIRROR}/binutils/binutils-2.19.1a.tar.bz2`)
* `MAKEFLAGS`:
  Flags to control Make's behaviour
  when compiling binutils and GCC.
  (default: `-j 4`)

[build-arg]: https://docs.docker.com/engine/reference/builder/#arg
