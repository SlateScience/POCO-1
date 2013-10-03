LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := PocoFoundation
LOCAL_SRC_FILES := ../lib/android/$(TARGET_ARCH_ABI)/libPocoFoundation.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE := PocoNet
LOCAL_SRC_FILES := ../lib/android/$(TARGET_ARCH_ABI)/libPocoNet.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE := PocoUtil
LOCAL_SRC_FILES := ../lib/android/$(TARGET_ARCH_ABI)/libPocoUtil.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE := PocoXML
LOCAL_SRC_FILES := ../lib/android/$(TARGET_ARCH_ABI)/libPocoXML.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE := PocoZip
LOCAL_SRC_FILES := ../lib/android/$(TARGET_ARCH_ABI)/libPocoZip.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
include $(PREBUILT_STATIC_LIBRARY)
