ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = DoubleAt7
DoubleAt7_FILES = Tweak.xm
DoubleAt7_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += doubleat7
include $(THEOS_MAKE_PATH)/aggregate.mk
