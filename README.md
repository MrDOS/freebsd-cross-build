# freebsd-cross-build

[![Git commits](https://img.shields.io/github/commit-activity/t/MrDOS/freebsd-cross-build)](https://github.com/MrDOS/freebsd-cross-build)
[![Docker pulls](https://img.shields.io/docker/pulls/empterdose/freebsd-cross-build)](https://hub.docker.com/r/empterdose/freebsd-cross-build)
[![Docker image size (v11.4)](https://img.shields.io/docker/image-size/empterdose/freebsd-cross-build/11.4)](https://hub.docker.com/r/empterdose/freebsd-cross-build)

Docker image to enable C/C++ cross-compilation
targeting FreeBSD 11.4
from a Linux host.
In addition to FreeBSD sysroots,
the Alpine 3.18-based image contains
Clang v16,
GCC (a dependency of Clang in Alpine; provides `ar` and `ranlib`),
LLD (the LLVM linker),
GNU Make,
`file`,
and the usual BusyBox shell environment.
Compared with other public and published containers,
it provides

* working unprivileged compilation
  (`docker run --user ...`),
* target support for x86_64, arm64, and i386
  (targets `x86_64-freebsd11`, `arm64-freebsd11`, and , `i386-freebsd11`,
  respectively),
* intact `termios` headers,
  and
* a competitive image size.

This work is based largely
on [Marco Cilloni's notes][mctut].

A previous version of this image
targeting FreeBSD 9.3 on x86_64 and i386 with a custom GCC build
(still available on the `9.3` Git branch/container image tag)
was based based on [Marcelo Gornstein's tutorial][mgtut]
and the [SpectraLogic container][spec].

[mctut]: https://mcilloni.ovh/2021/02/09/cxx-cross-clang/
[mgtut]: https://marcelog.github.io/articles/cross_freebsd_compiler_in_linux.html
[spec]: https://github.com/SpectraLogic/freebsd-cross-build

## Usage

    $ docker run --rm \
                 --user $(id --user):$(id --group) \
                 --volume /absolute/path/to/some/source:/workdir \
                 empterdose/freebsd-cross-build:11.4 \
                 settarget x86_64-freebsd11 make

The container's [working directory][workdir] is `/workdir`.
If you mount your source directory onto this path,
you can use relative paths in your build commands.

By default, the container overrides none of Make's [implicit variables][mkvar],
and the unprefixed compiler tools on the `PATH`
(`clang`, `clang++`, etc.)
target x86_64 Linux.
Do not use these
or the included GCC:
they will not produce FreeBSD binaries!
To build for FreeBSD,
either specifically invoke the prefixed utilities:

    $ docker run ... i386-freebsd11-clang -c -o foo.o foo.c

or use the `settarget` utility
to launch a subshell with environment variables (including the `PATH`)
set up for a particular target:

    $ docker run --name build \
                 --volume $(pwd):/workdir
                 --tty \
                 --detach \
                 empterdose/freebsd-cross-build:11.4
    # Build for 64-bit.
    $ docker exec build settarget x86_64-freebsd11 make
    # Do something to archive the build output.
    # `make(1)` is not target-specific.
    $ docker exec build make clean
    # Build for 32-bit.
    $ docker exec build settarget i386-freebsd11 make
    # Put our toys away.
    $ docker stop build

The image is based on Alpine Linux,
so any additional packages you might need
can be installed [via `apk`][apk].
Note that the image includes GNU Make, not BSD Make.

[workdir]: https://docs.docker.com/engine/reference/builder/#workdir
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
  (default: 3.18)
* `FBSD_VERSION`:
  The version of FreeBSD to target.
  (default: 11.4)
* `FBSD_MIRROR`:
  The mirror site/URL prefix for FreeBSD downloads.
  (default: https://archive.freebsd.org/old-releases)
* `FBSD_AMD64_BASE_URL`:
  The URL for the FreeBSD `base.txz` archive
  for the architecture that FreeBSD calls amd64
  (what many Linuxes call x86_64).
  (default: `${FBSD_MIRROR}/amd64/${FBSD_VERSION}-RELEASE/base.txz`)
* `FBSD_ARM64_BASE_URL`:
  The URL for the FreeBSD `base.txz` archive
  for the arm64 architecture.
  (default: `${FBSD_MIRROR}/arm64/${FBSD_VERSION}-RELEASE/base.txz`)
* `FBSD_I386_BASE_URL`:
  The URL for the FreeBSD `base.txz` archive
  for the i386 architecture.
  (default: `${FBSD_MIRROR}/i386/${FBSD_VERSION}-RELEASE/base.txz`)

[build-arg]: https://docs.docker.com/engine/reference/builder/#arg
