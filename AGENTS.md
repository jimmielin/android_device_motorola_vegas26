# Notes for coding agents

This file is for AI coding agents (and humans) building, modifying or
debugging LineageOS for the moto g power - 2026 (`vegas26`, XT2617V). Read
`README.md` first; this file adds the rules and the workflow that the
original bring-up depended on.

## Hard rules

These protect a phone that has no recovery path if they are broken. Treat
them as constraints, not suggestions, and ask the human before any action
that touches the phone.

1. **Never write bootloader-chain or firmware partitions**: `preloader*`,
   `lk*`, `tee*`, `gz*`, `sspm*`, `scp*`, `vcp*`, `spmfw*`, `mcupm*`, `dpm*`,
   `pi_img*`, `md1img*`, `connsys_*`, `seccfg`, `proinfo`, `nvram`, `nvdata`,
   `nvcfg`, `persist`, `protect*`, `efuse*`, `utags*`. The only exception is
   `mt6835-common/tools/copy-firmware-to-other-slot.sh`, which copies the
   phone's own running firmware to its other slot and verifies every write.
2. **Never flash firmware from another stock build**, even the same phone.
3. **Slot A only.** Name partitions with `_a` explicitly. Never run
   `fastboot --set-active`, A/B OTAs or recovery sideloads (they install to
   the other slot and switch to it) unless the other slot's firmware has been
   populated and the human has agreed.
4. **Flash `vbmeta_a` and `vbmeta_system_a` before the images they verify.**
   The Motorola bootloader checks each flashed image against the vbmeta on
   the device.
5. **Never lower the AVB rollback index (7) or the boot/vendor security patch
   level (2026-06-01).** `BOARD_AVB_ROLLBACK_INDEX` and `*_SECURITY_PATCH` in
   `BoardConfig.mk` encode them; KeyMint treats a lower patch level as a
   rollback.
6. **Never relock the bootloader** with a custom build installed.
7. **Never format or wipe user data on the human's behalf**, and never put a
   wipe into a flashing script. Tell them when it is needed (coming from
   stock or another ROM, or adding Google apps after the first boot) and let
   them run it.
8. Release images must not contain a developer's adb key or force adb on
   (`ro.adb.secure=0`, `persist.sys.usb.config=...adb`). Build bring-up
   images with `WITH_ADB_INSECURE=true` only for your own phone.

## Layout

| Path | Contents |
|---|---|
| `device/motorola/mt6835-common` | Shared MT6835 tree (vegas, vegas26): init, fstab, sepolicy, HAL configuration, the common blob list |
| `device/motorola/vegas26` | This device: kernel module lists, board sizes, blob list, overlays, `extract-files.py` |
| `device/motorola/vegas26-kernels` | Stock kernel Image, DTB, dtbo and modules, unmodified |
| `vendor/motorola/mt6835-common-vegas26` | Common blob list extracted from vegas26 stock |
| `vendor/motorola/vegas26` | Device blob list extracted from vegas26 stock |

`device/motorola/vegas26/extract-files.py` regenerates both vendor trees
from a stock dump: it loads the mt6835-common module, points it at
`vendor/motorola/mt6835-common-vegas26`, adds
`proprietary-files-mt6835-common.txt` and uses this tree's ImsService
patches.

## Build

```sh
source build/envsetup.sh
lunch lineage_vegas26-bp4a-userdebug
m bacon            # or: m bacon superimage, for a single super.img
```

Checks worth running on every build before anyone flashes it:

- `avbtool info_image --image vbmeta.img` and `vbmeta_system.img`:
  rollback index 7, security patch properties 2026-06-01 or later.
- The kernel in `boot.img` and the DTB in `vendor_boot.img` equal the stock
  ones in `vegas26-kernels` (`unpack_bootimg` and `cmp`).
- `lpdump` on an unsparsed `super.img`: 11475615744 bytes, only `_a`
  partitions have extents.

## Blob changes

- Shared libraries are resolved by name. Before building, check the
  DT_NEEDED closure of all three blob lists against the stock dump; missing
  libraries show up as Soong "depends on undefined module" errors only one
  layer at a time.
- Libraries loaded with dlopen never show up in DT_NEEDED. After a build,
  compare stock `vendor/lib64/hw`, `vendor/etc/vintf/manifest`,
  `vendor/etc/init` and `vendor/firmware` with `out/.../vendor` to catch them.
- A stock library whose name matches an AOSP module with a vendor variant
  (for example `libtflite`, radio AIDL `-V2-ndk` libraries) must be shipped
  under a new file name (`*_vendor.so`, `fix_soname()`, `replace_needed()` in
  its users). `MODULE_SUFFIX` alone still collides at install time.

## Debugging a phone that does not boot

- Bring-up builds with `WITH_ADB_INSECURE=true` give adb from early boot,
  including when the display does not work.
- The kernel log of a failed boot survives a warm reset in pstore: hold
  Power + Volume down (do not power off), and read
  `/sys/fs/pstore/console-ramoops-0` and `pmsg-ramoops-0` (logcat, including
  tombstones) from LineageOS recovery's adb shell, or after restoring stock
  boot images.
- LineageOS recovery runs adb as root and can read every partition, which is
  also how to back up a phone that has no other root.

## Hardware notes

- Stock vendor serves both vegas and vegas26; variant-specific behaviour keys
  off `ro.boot.radio` (`NA` vegas, `NA2` vegas26), dtbo index 2 and files named
  "orlando".
- The primary charger (sc89890h) is at i2c-5 0x6a; its power supply needs the
  genfs label in `sepolicy/vendor/genfs_contexts` for the health HAL to see
  the charger.
- The fingerprint sensor is FPC; `init.oem.fingerprint.sh` probes FPC and
  Goodix and caches the result in `/mnt/vendor/persist/fps/vendor_id`.
