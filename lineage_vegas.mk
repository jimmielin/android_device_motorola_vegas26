#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
# The MT6835 stock vendor has no 32-bit binaries.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/motorola/vegas/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

TARGET_BOOT_ANIMATION_RES := 1080

PRODUCT_NAME := lineage_vegas
PRODUCT_DEVICE := vegas
PRODUCT_MANUFACTURER := motorola
PRODUCT_BRAND := motorola
PRODUCT_MODEL := moto g power - 2025

PRODUCT_GMS_CLIENTID_BASE := android-motorola

PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceName=vegas \
    BuildDesc="vegas_g_sys-user 16 W1VES36H.10-12-9-8-4 366285-16991f release-keys" \
    BuildFingerprint=motorola/vegas_g_sys/vegas:16/W1VES36H.10-12-9-8-4/366285-16991f:user/release-keys
