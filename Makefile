# The version of Ubuntu to use in the Docker image.
UBUNTU_VERSION := 18.04

# The FreeBSD version to target for cross-compilation.
FBSD_VERSION := 9.3
FBSD_MIRROR := http://ftp-archive.freebsd.org/pub/FreeBSD-Archive/old-releases
FBSD_I386_BASE_ARCHIVE := fbsd-$(FBSD_VERSION)-i386-base.txz
FBSD_I386_BASE_URL := $(FBSD_MIRROR)/i386/$(FBSD_VERSION)-RELEASE/base.txz
FBSD_AMD64_BASE_ARCHIVE := fbsd-$(FBSD_VERSION)-amd64-base.txz
FBSD_AMD64_BASE_URL := $(FBSD_MIRROR)/amd64/$(FBSD_VERSION)-RELEASE/base.txz

GNU_MIRROR := https://ftp.gnu.org/gnu

# FreeBSD 9.3 includes GCC 4.2.1; 4.2.4 is the last patch version in the 4.2.x
# series. We want to keep the compiler version pretty close to that included
# with the distro so we retain compatibility with the original libgcc.
GCC_VERSION := 4.2.4
GCC_ARCHIVE := gcc-$(GCC_VERSION).tar.bz2
GCC_URL := $(GNU_MIRROR)/gcc/gcc-$(GCC_VERSION)/$(GCC_ARCHIVE)
# Per https://wiki.osdev.org/Cross-Compiler_Successful_Builds, binutils
# versions above 2.19.1 are uncharted territory with GCC 4.2.
BINUTILS_VERSION := 2.19.1a
BINUTILS_ARCHIVE := binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_URL := $(GNU_MIRROR)/binutils/$(BINUTILS_ARCHIVE)
# Lots of cross-compiler guides include instructions for compiling MPC, MPFR,
# and GMP. Don't: these are dependencies required for compiling GCC itself, and
# do not affect the compiled output. Per GCC's own documented recommendation
# (https://gcc.gnu.org/wiki/InstallingGCC), we'll use the libraries provided by
# our distro package manager.

DL := wget
DLO := -O

# If you don't have wget on your host (e.g., macOS):
#DL := curl
#DLO := -o

all: freebsd-cross-build

freebsd-cross-build: ubuntu-build \
                     $(FBSD_AMD64_BASE_ARCHIVE) \
                     $(FBSD_I386_BASE_ARCHIVE) \
                     $(GCC_ARCHIVE) \
                     $(BINUTILS_ARCHIVE)
	docker build --tag freebsd-cross-build:$(FBSD_VERSION) \
	             --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
	             --build-arg FBSD_VERSION=$(FBSD_VERSION) \
	             --build-arg FBSD_AMD64_BASE_ARCHIVE=$(FBSD_AMD64_BASE_ARCHIVE) \
	             --build-arg FBSD_I386_BASE_ARCHIVE=$(FBSD_I386_BASE_ARCHIVE) \
	             --build-arg BINUTILS_ARCHIVE=$(BINUTILS_ARCHIVE) \
	             --build-arg GCC_ARCHIVE=$(GCC_ARCHIVE) \
	             .

ubuntu-build:
	docker build --tag ubuntu-build:$(UBUNTU_VERSION) \
	             --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
	             --file ubuntu-build.dockerfile \
	             .

$(FBSD_I386_BASE_ARCHIVE):
	$(DL) $(DLFLAGS) $(DLO)$@ $(FBSD_I386_BASE_URL)

$(FBSD_AMD64_BASE_ARCHIVE):
	$(DL) $(DLFLAGS) $(DLO)$@ $(FBSD_AMD64_BASE_URL)

$(BINUTILS_ARCHIVE):
	$(DL) $(DLFLAGS) $(DLO)$@ $(BINUTILS_URL)

$(GCC_ARCHIVE):
	$(DL) $(DLFLAGS) $(DLO)$@ $(GCC_URL)
