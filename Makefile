ARCHS = arm64
ifeq ($(SIM),1)
	TARGET = simulator:clang:17.2:14.0
	ARCHS += x86_64
	THEOS_PACKAGE_SCHEME =
	THEOS_PACKAGE_INSTALL_PREFIX = /opt/simject
else
	TARGET = iphone:clang:16.5:14.0
	ARCHS += arm64e
	THEOS_PACKAGE_SCHEME = rootless
endif

INSTALL_TARGET_PROCESSES = MobileSMS


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iMessageRetweet

iMessageRetweet_FILES = Tweak.x
iMessageRetweet_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

deploy:: package
ifeq ($(SIM),1)
	@echo "Deploying to simulator..."
	sudo cp $(THEOS_STAGING_DIR)/$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib
	sudo cp $(THEOS_STAGING_DIR)/$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).plist $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).plist

# 	sudo mkdir -p $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Tweak\ Support/$(TWEAK_NAME).bundle
# 	sudo cp -r $(THEOS_STAGING_DIR)/$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Tweak\ Support/$(TWEAK_NAME).bundle/* $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Tweak\ Support/$(TWEAK_NAME).bundle/

	@echo "Restarting SpringBoard..."
	resim
else
	@echo "Deploying to physical device..."
	@$(MAKE) install
endif