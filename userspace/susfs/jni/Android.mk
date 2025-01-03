LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := susfs
LOCAL_SRC_FILES := susfs.c
include $(BUILD_EXECUTABLE)
