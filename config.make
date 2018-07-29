# Makefile
# Copyright © 2018 ZeeZide GmbH. All rights reserved.

prefix = /usr/local

CONFIGURATION=Release
BUILD_DIR=build

DERIVED_DATA_DIR=$(BUILD_DIR)/DerivedData

MKDIR_P     = mkdir -p
INSTALL     = cp
UNINSTALL   = rm -f

SWIFT_PROGRESS_BUILD_RESULT = $(DERIVED_DATA_DIR)/Build/Products/$(CONFIGURATION)/$(PACKAGE_NAME)

ifeq ($(BINARY_INSTALL_DIR),)
  BINARY_INSTALL_DIR=$(prefix)/bin
endif
