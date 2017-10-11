LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libGCloudVoice
LOCAL_MODULE_FILENAME := libGCloudVoice
LOCAL_SRC_FILES := ../../../Gvoice/libs/Android/$(TARGET_ARCH_ABI)/libGCloudVoice.so 
include $(PREBUILT_SHARED_LIBRARY)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../Classes/AppDelegate.cpp \
../../../cocos2d-x/cocos/scripting/lua-bindings/auto/lua_MJGame_auto.cpp \
hellolua/main.


#### 引入所有的.cpp和.c-------------begin

APP_FILES_PATH  :=  $(LOCAL_PATH) \
					$(LOCAL_PATH)/../../Classes/pbc \
					$(LOCAL_PATH)/../../Classes/ide-support \
					$(LOCAL_PATH)/../../Classes/MJToLua \
					$(LOCAL_PATH)/../../Classes/Gvoice 

APP_FILES_SUFFIX := %.cpp %.c
# 递归遍历目录下的所有的文件  
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
# 获取相应的源文件
APP_ALL_FILES := $(foreach src_path,$(APP_FILES_PATH), $(call rwildcard,$(src_path),*.*) )
APP_ALL_FILES := $(APP_ALL_FILES:$(APP_CPP_PATH)/./%=$(APP_CPP_PATH)%)
APP_ALL_FILES := $(filter %.cpp %.c,$(APP_ALL_FILES))
APP_SRC_LIST  := $(APP_ALL_FILES:$(LOCAL_PATH)/%=%)

#$(warning printup______________________)
#$(warning $(APP_SRC_LIST))
#$(warning printdown____________________)

# 去除字串的重复单词
define uniq =
  $(eval seen :=)
  $(foreach _,$1,$(if $(filter $_,${seen}),,$(eval seen += $_)))
  ${seen}
endef
LOCAL_SRC_FILES  += $(APP_SRC_LIST)

#### 引入所有的.cpp和.c-------------end

#### 引入所有的.h-------------begin

# 递归遍历获取所有目录
APP_ALL_DIRS := $(dir $(foreach src_path,$(APP_FILES_PATH), $(call rwildcard,$(src_path),*/) ) )
APP_ALL_DIRS := $(call uniq,$(APP_ALL_DIRS))
LOCAL_C_INCLUDES := $(APP_ALL_DIRS)

LOCAL_C_INCLUDES += \
$(LOCAL_PATH)/../../Classes/protobuf-lite \
$(LOCAL_PATH)/../../Classes/runtime \
$(LOCAL_PATH)/../../Classes \
$(LOCAL_PATH)/../../../Gvoice/include \
$(LOCAL_PATH)/../../../cocos2d-x/external \
$(LOCAL_PATH)/../../../cocos2d-x/tools/simulator/libsimulator/lib

#### 引入所有的.h-------------end

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END



LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
# LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static
LOCAL_STATIC_LIBRARIES += quick_libs_static

# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

LOCAL_SHARED_LIBRARIES += libGCloudVoice
include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings/proj.android)
$(call import-module,tools/simulator/libsimulator/proj.android)
$(call import-module,quick_libs/proj.android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
