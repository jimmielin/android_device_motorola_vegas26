# Device tree for moto g power - 2026 (vegas26)

LineageOS 23.2 device tree for the Motorola moto g power - 2026
(XT2617V, codename `vegas26`), built on `device/motorola/mt6835-common`.

vegas26 is a hardware respin of the moto g power - 2025 (`vegas`), and this
tree is forked from `device/motorola/vegas`. Motorola's stock vendor image for
this phone covers both models: dtbo overlays 0/1 are vegas, overlay 2 is
vegas26, and vegas26-only parts are named "orlando" (`ro.boot.radio=NA2`).

| | |
|---|---|
| SoC | MediaTek MT6835 (Dimensity 6300): 2x Cortex-A76 + 6x Cortex-A55, Mali-G57 MC2 |
| Kernel | Google GKI 5.15 (android13-5.15), prebuilt from stock (`vegas26-kernels`) |
| Display | TXD FT8725 1080x2388, 120 Hz, Focaltech in-cell touch (ILITEK 77600 alternative) |
| Cameras | 50 MP OV50D, 8 MP OV08D ultrawide, S5KKDS front |
| Fingerprint | FPC, side-mounted in the power key (Goodix also supported by stock) |
| NFC | NXP SN220 (AOSP NXP HAL from `hardware/nxp/nfc`), vegas26 RF tuning |
| Audio | MT6377 codec, AWINIC aw883xx amplifier |
| Storage / partitions | UFS, Virtual A/B with compression, `init_boot`, super 11475615744 bytes |

## Status

Working: display and touch, all three cameras with flash, fingerprint,
speaker and media audio, vibration, auto-rotate, Wi-Fi, Bluetooth, GPS, NFC,
mobile data, calls and SMS, charging, Google apps (MindTheGapps).

Not yet verified: VoLTE/VoWiFi, A/B updates from the LineageOS updater
(update by flashing images for now).

## Requirements

- An unlocked bootloader.
- **Stock firmware `W1WEOS36.48-22-3-3-4-3` on slot A.** The proprietary files
  in this build come from that firmware, and the Trustonic trustlets, kernel
  modules and modem-facing HALs must match the bootloader-chain firmware
  (TEE, modem) on the phone. `fastboot getvar version-bootloader` must end in
  `W1WEOS36.48-22-3-3-4-3-...`.

## Flashing safety

This phone has no known BROM rescue path: a damaged bootloader chain is a
permanent brick.

- Only `boot`, `init_boot`, `vendor_boot`, `dtbo`, `vbmeta`, `vbmeta_system`
  and the logical partitions in `super` are ever flashed. Never flash
  `preloader`, `lk`, `tee`, `gz`, `md1img` or other firmware partitions, and
  never flash firmware from a different stock build.
- The Motorola bootloader validates each image against the vbmeta currently on
  the device, so flash `vbmeta` and `vbmeta_system` first.
- Stock ships with only slot A populated: slot B's bootloader (`lk_b`) and
  other firmware are empty. Flash slot A explicitly and never switch slots.
  After installing, run `mt6835-common/tools/copy-firmware-to-other-slot.sh`
  as root (for example from LineageOS recovery's adb shell) so a bootloader
  fallback to slot B reaches fastboot instead of an empty LK.
- Images keep the stock AVB rollback index (7) and a boot/vendor security
  patch level no lower than stock (2026-06-01).
- There is no stock firmware package for this build online. Before flashing
  anything, back up every partition of your phone.

## Installing a release

1. **Back up the phone** and check the requirements above.
2. Unzip the release and put the phone in bootloader fastboot mode. From the
   release directory:

   ```sh
   ./flash-vegas26.sh
   ```

   It checks the SKU, the slot and the stock firmware version, flashes vbmeta
   and the boot images to slot A in the bootloader, then reboots to fastbootd
   and flashes the logical partitions. It also ships in `tools/`.
3. **Format data**, if you are coming from stock or another ROM. LineageOS
   cannot use stock's encrypted data, and the phone will not boot past it.
   This erases everything on the phone, so the script leaves it to you:

   ```sh
   fastboot -w
   ```

   Skip this step when updating an existing install of these builds.
4. **Optional: Google apps.** Install them before the first boot, or you will
   have to format data again. Download MindTheGapps for Android 16 arm64 from
   <https://github.com/MindTheGapps/16.0.0-arm64/releases>, then:

   ```sh
   fastboot reboot recovery
   ```

   In recovery, choose *Apply update* > *Apply from ADB*, and run
   `adb sideload MindTheGapps-16.0.0-arm64-<date>.zip`. Accept the signature
   warning: the package is not signed with this build's keys.
5. Reboot (`fastboot reboot`, or *Reboot system now* in recovery).
6. Once, as root, copy the firmware to the empty slot B. For example, from
   LineageOS recovery with *Advanced* > *Enable ADB*:

   ```sh
   adb push copy-firmware-to-other-slot.sh /tmp/
   adb shell sh /tmp/copy-firmware-to-other-slot.sh
   ```

## Building

Add the trees with a local manifest, for example
`.repo/local_manifests/vegas26.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project path="device/motorola/vegas26" name="jimmielin/android_device_motorola_vegas26" remote="github" revision="lineage-23.2" />
  <project path="device/motorola/vegas26-kernels" name="jimmielin/android_device_motorola_vegas26-kernels" remote="github" revision="lineage-23.2" />
  <project path="device/motorola/mt6835-common" name="jimmielin/android_device_motorola_mt6835-common" remote="github" revision="lineage-23.2" />
  <project path="vendor/motorola/vegas26" name="jimmielin/android_vendor_motorola_vegas26" remote="github" revision="lineage-23.2" />
  <project path="vendor/motorola/mt6835-common-vegas26" name="jimmielin/android_vendor_motorola_mt6835-common-vegas26" remote="github" revision="lineage-23.2" />
  <project path="hardware/mediatek" name="LineageOS/android_hardware_mediatek" remote="github" revision="lineage-23.2" />
  <project path="device/mediatek/sepolicy_vndr" name="LineageOS/android_device_mediatek_sepolicy_vndr" remote="github" revision="lineage-23.2" />
  <project path="hardware/motorola" name="LineageOS/android_hardware_motorola" remote="github" revision="lineage-23.2" />
</manifest>
```

Then:

```sh
source build/envsetup.sh
lunch lineage_vegas26-bp4a-userdebug
m bacon
```

Sign with your own release keys
([LineageOS signing guide](https://wiki.lineageos.org/signing_builds)). On a
sibling Motorola MediaTek phone, the Trustonic TEE daemon handled trustlets
differently on test-keys builds; this tree has only been tested with
release keys.

## Proprietary files

Proprietary files come from stock `W1WEOS36.48-22-3-3-4-3`; regenerate them
with `./extract-files.py <dump>` against a dump of that build (partition-root
layout: `vendor/`, `system/`, `system_ext/`, `product/`, ...).

That firmware line rebuilds the kernel modules, Trustonic trustlets and
several HALs, so the blobs in mt6835-common's `proprietary-files.txt` are
extracted from vegas26 stock into `vendor/motorola/mt6835-common-vegas26`
(selected with `MT6835_COMMON_VENDOR_PATH`) instead of being shared with
vegas. `proprietary-files-mt6835-common.txt` lists the extra libraries those
blobs need, and `patches/ImsService` is the common ImsService patch set with
patch 0005 rebased onto the vegas26 smali, whose debug line numbers differ.

For coding agents and maintainers, `AGENTS.md` lists the invariants and the
debugging workflow used to bring this device up.
