ARCHS = armv7 arm64
TARGET = :clang
THEOS_PACKAGE_DIR_NAME = debs

include theos/makefiles/common.mk

TWEAK_NAME = NoAlertLoop
NoAlertLoop_FILES = Tweak.xm
NoAlertLoop_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari"
SUBPROJECTS += noalertloopprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
