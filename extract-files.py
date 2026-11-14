#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/motorola/mt6835-common',
    'vendor/motorola/mt6835-common',
    'device/motorola/vegas',
    'hardware/mediatek',
    'hardware/motorola',
]

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
}

blob_fixups: blob_fixups_user_type = {
    'vendor/lib64/mt6835/libcam.utils.sensorprovider.so': blob_fixup()
        .add_needed('android.hardware.sensors@1.0-convert-shared.so'),
    (
        'vendor/lib64/hw/mt6835/android.hardware.camera.provider@2.6-impl-mediatek.so',
        'vendor/lib64/mt6835/libmtkcam_stdutils.so',
    ): blob_fixup()
        .replace_needed('libutils.so', 'libutils-v32.so')
        .add_needed('libbase_shim.so'),
    'vendor/lib64/mt6835/lib3a.ae.stat.so': blob_fixup()
        .add_needed('liblog.so'),
    'vendor/lib64/mt6835/libcam.hal3a.v3.so': blob_fixup()
        .add_needed('libprocessgroup_shim.so'),
}  # fmt: skip

# Firmware partition images are deliberately not packaged: this device has no
# BROM recovery path, so builds must never touch the bootloader chain.
module = ExtractUtilsModule(
    'vegas',
    'motorola',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device_with_common(
        module, 'mt6835-common', module.vendor
    )
    utils.run()
