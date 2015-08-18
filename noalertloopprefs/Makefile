ARCHS = armv7 arm64
TARGET = :clang

include theos/makefiles/common.mk

BUNDLE_NAME = NoAlertLoopPrefs
NoAlertLoopPrefs_FILES = NoAlertLoopPrefs.mm
NoAlertLoopPrefs_INSTALL_PATH = /Library/PreferenceBundles
NoAlertLoopPrefs_FRAMEWORKS = UIKit
NoAlertLoopPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NoAlertLoopPrefs.plist$(ECHO_END)
