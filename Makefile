# Makefile
# Copyright © 2018 ZeeZide GmbH. All rights reserved.

PACKAGE_NAME = swift-progress

include config.make

all : $(SWIFT_PROGRESS_BUILD_RESULT) 

clean : 
	rm -rf build

distclean : clean

install : all
	$(MKDIR_P) $(BINARY_INSTALL_DIR)/
	$(INSTALL) $(SWIFT_PROGRESS_BUILD_RESULT) $(BINARY_INSTALL_DIR)/

uninstall :
	$(UNINSTALL) $(BINARY_INSTALL_DIR)/swift-progress

# rules

$(SWIFT_PROGRESS_BUILD_RESULT) :
	xcodebuild -target $(PACKAGE_NAME) \
	           -configuration $(CONFIGURATION) \
		   -scheme $(PACKAGE_NAME) \
		   -derivedDataPath $(DERIVED_DATA_DIR)
