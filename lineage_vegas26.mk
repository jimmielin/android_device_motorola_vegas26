#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
# The MT6835 stock vendor has no 32-bit binaries.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/motorola/vegas26/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

TARGET_BOOT_ANIMATION_RES := 1080

PRODUCT_NAME := lineage_vegas26
PRODUCT_DEVICE := vegas26
PRODUCT_MANUFACTURER := motorola
PRODUCT_BRAND := motorola
PRODUCT_MODEL := moto g power - 2026

PRODUCT_GMS_CLIENTID_BASE := android-motorola

PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceName=vegas26 \
    BuildDesc="vegas_og_sys-user 16 W1WEOS36.48-22-3-3-4-3 7806ed-c4dcce release-keys" \
    BuildFingerprint=motorola/vegas_og_sys/vegas26:16/W1WEOS36.48-22-3-3-4-3/7806ed-c4dcce:user/release-keys
