# SPDX-FileCopyrightText: Copyright (c) 2024-2025 by Rivos Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Variables
export SHELL := /bin/bash
export WORKSPACE := $(shell pwd)
export EDK_SOURCES := $(WORKSPACE)
export EDK_PLATFORMS := $(WORKSPACE)/edk2-platforms
export EDK_TOOLS := $(WORKSPACE)/BaseTools
export CONF_PATH := $(WORKSPACE)/Conf
export PACKAGES_PATH := $(WORKSPACE):$(EDK_PLATFORMS)
export GCC5_RISCV64_PREFIX := riscv64-linux-gnu-
PAYLOAD_SCRIPT = $(WORKSPACE)/UefiPayloadPkg/UniversalPayloadBuild.py
PAYLOAD_OPTIONS = -t GCC5 --Fit -a RISCV64 -l $(FD_BASE) -c $(EDK_PLATFORMS)/Platform/Rivos/RivosPlatformPkg/UefiPayloadPkg.dsc
DEBUG_PAYLOAD = ./Build/UefiPayloadPkgRISCV64/DEBUG_GCC5/FV/UEFIPAYLOAD.fd
RELEASE_PAYLOAD = ./Build/UefiPayloadPkgRISCV64/RELEASE_GCC5/FV/UEFIPAYLOAD.fd

VENV := $(WORKSPACE)/.venv
# Force our shiny new venv onto the PATH
export PATH := $(VENV)/bin:$(PATH)
export PYTHON := $(VENV)/bin/python3
export PIP := $(VENV)/bin/pip
FD_BASE := 2415919104 # 0x90000000 in decimal

# Default target
.PHONY: all
all: init-submodules symlink-platforms init-env base-tools $(DEBUG_PAYLOAD) $(RELEASE_PAYLOAD)

# Initialize Git Submodules
.PHONY: init-submodules
init-submodules:
	git submodule update --init --recursive

# symlink to ../edk2-platforms - build requires it in .
.PHONY: symlink-platforms
symlink-platforms:
	@if [[ ! -d ../edk2-platforms ]]; then \
	    echo "ERROR: ../edk2-platforms does not exist. Aborting."; \
	    exit 1; \
	fi
	ln -snf ../edk2-platforms edk2-platforms

# Initialize the virtual environment
.PHONY: init-env
init-env:
	@if [ ! -f "$(PYTHON)" ]; then \
	    python3 -m venv $(VENV); \
       . $(EDK_SOURCES)/.venv/bin/activate && \
	    $(PIP) install -r $(WORKSPACE)/pip-requirements.txt --upgrade; \
	fi

# Build BaseTools
.PHONY: base-tools
base-tools:
	. $(WORKSPACE)/edksetup.sh BaseTools && \
	$(MAKE) -C $(EDK_TOOLS) && \
	$(MAKE) -C $(EDK_TOOLS)/Source/C

# Build Universal Payload
.PHONY: build-payloads
build-payloads: $(DEBUG_PAYLOAD) $(RELEASE_PAYLOAD)

# DEBUG version of the payload
$(DEBUG_PAYLOAD):
	. $(WORKSPACE)/edksetup.sh BaseTools && \
    $(PYTHON) $(PAYLOAD_SCRIPT) $(PAYLOAD_OPTIONS)

# RELEASE version of the payload used by the SPI flash image
$(RELEASE_PAYLOAD):
	. $(WORKSPACE)/edksetup.sh BaseTools && \
    $(PYTHON) $(PAYLOAD_SCRIPT) $(PAYLOAD_OPTIONS) -b RELEASE

# Clean up
.PHONY: clean
clean:
	rm -rf $(WORKSPACE)/Build $(VENV) edk2-platforms
	$(MAKE) -C $(EDK_TOOLS) clean
