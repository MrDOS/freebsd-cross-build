# See README.md and Dockerfile for explanations of these values.

FBSD_VERSION ?= $(shell grep '^ARG FBSD_VERSION=' Dockerfile | head -n 1 | cut -d = -f 2)

ifdef ALPINE_VERSION
ALPINE_VERSION_ARG := ALPINE_VERSION=$(ALPINE_VERSION)
endif
FBSD_VERSION_ARG := FBSD_VERSION=$(FBSD_VERSION)
ifdef FBSD_MIRROR
FBSD_MIRROR_ARG := FBSD_MIRROR=$(FBSD_MIRROR)
endif
ifdef FBSD_AMD64_BASE_URL
FBSD_AMD64_BASE_URL_ARG := FBSD_AMD64_BASE_URL=$(FBSD_AMD64_BASE_URL)
endif
ifdef FBSD_ARM64_BASE_URL
FBSD_ARM64_BASE_URL_ARG := FBSD_ARM64_BASE_URL=$(FBSD_ARM64_BASE_URL)
endif
ifdef FBSD_I386_BASE_URL
FBSD_I386_BASE_URL_ARG := FBSD_I386_BASE_URL=$(FBSD_I386_BASE_URL)
endif

# https://docs.docker.com/engine/reference/builder/#predefined-args
ifdef HTTP_PROXY
HTTP_PROXY_ARG := HTTP_PROXY=$(HTTP_PROXY)
endif
ifdef HTTPS_PROXY
HTTPS_PROXY_ARG := HTTPS_PROXY=$(HTTPS_PROXY)
endif
ifdef FTP_PROXY
FTP_PROXY_ARG := FTP_PROXY=$(FTP_PROXY)
endif
ifdef NO_PROXY
NO_PROXY_ARG := NO_PROXY=$(NO_PROXY)
endif

BUILD_ARGS := $(addprefix --build-arg ,$(ALPINE_VERSION_ARG) \
                                       $(FBSD_VERSION_ARG) \
                                       $(FBSD_MIRROR_ARG) \
                                       $(FBSD_AMD64_BASE_URL_ARG) \
                                       $(FBSD_ARM64_BASE_URL_ARG) \
                                       $(FBSD_I386_BASE_URL_ARG) \
                                       $(HTTP_PROXY) \
                                       $(HTTPS_PROXY) \
                                       $(FTP_PROXY) \
                                       $(NO_PROXY))

freebsd-cross-build:
	docker build --tag freebsd-cross-build:$(FBSD_VERSION) $(BUILD_ARGS) .
