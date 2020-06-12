# freebsd-cross-build

Docker image to enable C/C++ cross-compilation
targeting FreeBSD
from a Linux host.
The container defaults to building for an Ubuntu 18.04 host,
and a FreeBSD 9.3 target.
Compared with other public and published containers,
it provides

* unprivileged compilation works
  (`docker run --user ...`)
* both 32- and 64-bit compilation
  (`x86_64-freebsd9-` and `i386-freebsd9-` prefixes)
* intact `termios` headers

It's based on [Marcelo Gornstein's tutorial][mgtut]
and the [SpectraLogic container][spec].

[mgtut]: https://marcelog.github.io/articles/cross_freebsd_compiler_in_linux.html
[spec]: https://github.com/SpectraLogic/freebsd-cross-build
