export TARGET = iphone:clang:14.0:12.0
export ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = ffmenu
ffmenu_FILES = Tweak.x
ffmenu_CFLAGS = -fobjc-arc
ffmenu_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tool.mk
