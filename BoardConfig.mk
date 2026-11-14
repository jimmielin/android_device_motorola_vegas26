#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/motorola/vegas
KERNEL_PATH := $(DEVICE_PATH)-kernels

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := vegas

# Display
TARGET_SCREEN_DENSITY := 390

# Kernel
TARGET_KERNEL_DIR := $(KERNEL_PATH)/5.15
TARGET_PROVIDES_STATIC_MODULE_LISTS := true

BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(TARGET_KERNEL_DIR)/vendor_dlkm.modules.load))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(TARGET_KERNEL_DIR)/vendor_ramdisk.modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(TARGET_KERNEL_DIR)/vendor_ramdisk.modules.load.recovery))

BOARD_KERNEL_MODULE_DIR := $(TARGET_KERNEL_DIR)
BOARD_PREBUILT_DTBIMAGE_DIR := $(TARGET_KERNEL_DIR)
BOARD_PREBUILT_DTBOIMAGE := $(TARGET_KERNEL_DIR)/dtbo.img
# Deferred: BOARD_KERNEL_IMAGE_NAME is set by BoardConfigCommon.mk, included below.
TARGET_PREBUILT_KERNEL = $(TARGET_KERNEL_DIR)/$(BOARD_KERNEL_IMAGE_NAME)
TARGET_PREBUILT_KERNEL_HEADERS := $(TARGET_KERNEL_DIR)/kernel-uapi-headers.tar.gz

ALL_VENDOR_RAMDISK_MODULES := $(sort $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD) $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD))
BOARD_VENDOR_KERNEL_MODULES := $(addprefix $(BOARD_KERNEL_MODULE_DIR)/,$(BOARD_VENDOR_KERNEL_MODULES_LOAD))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(addprefix $(BOARD_KERNEL_MODULE_DIR)/,$(ALL_VENDOR_RAMDISK_MODULES))

# Modules stock loads from init scripts rather than modules.load: connectivity
# drivers, touch, fingerprint, NFC, SAR, haptics, charging and Moto helpers.
BOARD_VENDOR_KERNEL_MODULES += \
    $(addprefix $(BOARD_KERNEL_MODULE_DIR)/, \
        aw862x_haptic_nv_v1.ko \
        bt_drv_connac1x.ko \
        connfem.ko \
        fmradio_drv_mt6631_6635.ko \
        fpc_mtk_tee.ko \
        goodix_fps_tee.ko \
        gps_drv_stp.ko \
        gps_pwr.ko \
        ilitek_v3_mmi.ko \
        mmi_info.ko \
        mmi_stow.ko \
        moto_binder.ko \
        moto_f_usbnet.ko \
        moto_mmap_fault.ko \
        moto_sched.ko \
        moto_swap.ko \
        nova_0flash_mmi_v3.ko \
        nxp_i2c.ko \
        qpnp_adaptive_charge.ko \
        sensors_class.ko \
        sx937x_sar.ko \
        utags.ko \
        wlan_drv_gen4m_6835.ko \
        wmt_chrdev_wifi.ko \
        wmt_drv.ko)

# Partitions
BOARD_SUPER_PARTITION_SIZE := 10166992896
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_SIZE := 10162798592 # (BOARD_SUPER_PARTITION_SIZE - 4MiB)

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Security patch level
# Never below stock (W1VES36H.10-12-9-8-4): KeyMint treats a lower boot or
# vendor patch level as a rollback.
BOOT_SECURITY_PATCH := 2026-08-01
VENDOR_SECURITY_PATCH := 2026-08-01

# Verified Boot
# The bootloader keeps stock's rollback index 21 for vbmeta (location 0) and
# vbmeta_system (location 2); images must not go below it.
BOARD_AVB_ROLLBACK_INDEX := 21
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 21

# Inherit from mt6835-common
include device/motorola/mt6835-common/BoardConfigCommon.mk

# Inherit the proprietary files
include vendor/motorola/vegas/BoardConfigVendor.mk
