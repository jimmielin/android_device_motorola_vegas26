#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from os import path

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
from extract_utils.tools import android_root

namespace_imports = [
    'device/motorola/mt6835-common',
    'vendor/motorola/mt6835-common-vegas26',
    'device/motorola/vegas26',
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
    'vegas26',
    'motorola',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)


def vegas26_common_module():
    # The shared blob list is extracted from vegas26 stock into its own tree:
    # the W1WEOS36 firmware line rebuilds kernel modules, Trustonic trustlets
    # and several HALs, so these blobs cannot be shared with vegas.
    common = ExtractUtils.get_module('mt6835-common', module.vendor)
    common.vendor_rel_path = path.join('vendor', module.vendor, 'mt6835-common-vegas26')
    common.vendor_path = path.join(android_root, common.vendor_rel_path)
    common.vendor_rro_path = path.join(common.vendor_path, 'rro_overlays')
    common.add_proprietary_file(
        path.join(module.device_path, 'proprietary-files-mt6835-common.txt')
    )
    # Stock radio AIDL version 2 libraries, renamed to *_vendor.so (see
    # proprietary-files-mt6835-common.txt), and the library that links them.
    config_v2 = 'android.hardware.radio.config-V2-ndk'
    sim_v2 = 'android.hardware.radio.sim-V2-ndk'
    common.blob_fixups.update({
        f'vendor/lib64/{config_v2}_vendor.so': blob_fixup()
            .fix_soname(),
        f'vendor/lib64/{sim_v2}_vendor.so': blob_fixup()
            .fix_soname()
            .replace_needed(f'{config_v2}.so', f'{config_v2}_vendor.so'),
        'vendor/lib64/librilfusion.so': blob_fixup()
            .replace_needed(f'{config_v2}.so', f'{config_v2}_vendor.so')
            .replace_needed(f'{sim_v2}.so', f'{sim_v2}_vendor.so'),
        'vendor/lib64/libtflite_vendor.so': blob_fixup()
            .fix_soname(),
        'vendor/lib64/libmtk-ril.so': blob_fixup()
            .replace_needed('libtflite.so', 'libtflite_vendor.so'),
        'vendor/lib64/libmtkmipc-ril.so': blob_fixup()
            .replace_needed('libtflite.so', 'libtflite_vendor.so'),
    })  # fmt: skip
    # The vegas26 ImsService smali differs slightly from vegas, so it carries
    # its own rebase of the common ImsService patches.
    common.blob_fixups['system_ext/priv-app/ImsService/ImsService.apk'] = (
        blob_fixup().apktool_patch(
            path.join(module.device_path, 'patches', 'ImsService')
        )
    )
    return common


if __name__ == '__main__':
    utils = ExtractUtils(module, [vegas26_common_module()])
    utils.run()
