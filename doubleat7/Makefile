ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = DoubleAt7
DoubleAt7_FILES = DoubleAt7.mm
DoubleAt7_INSTALL_PATH = /Library/PreferenceBundles
DoubleAt7_FRAMEWORKS = UIKit
DoubleAt7_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DoubleAt7.plist$(ECHO_END)
