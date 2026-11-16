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

## Building

```sh
source build/envsetup.sh
lunch lineage_vegas26-bp4a-userdebug
m bacon
```

Proprietary files come from stock `W1WEOS36.48-22-3-3-4-3`; regenerate them
with `./extract-files.py <dump>` against a dump of that build (partition-root
layout: `vendor/`, `system/`, `system_ext/`, `product/`, ...).

That firmware line rebuilds the kernel modules, Trustonic trustlets and
several HALs, so the blobs in mt6835-common's `proprietary-files.txt` are
extracted from vegas26 stock into `vendor/motorola/mt6835-common-vegas26`
(selected with `MT6835_COMMON_VENDOR_PATH`) instead of being shared with
vegas. `proprietary-files-mt6835-common.txt` lists the extra libraries those
blobs need, and `patches/ImsService` is the common ImsService patch set
rebased onto the vegas26 smali.

## Flashing safety

This device has no known BROM rescue path: a damaged bootloader chain is a
permanent brick. Builds only ever produce and flash `boot`, `init_boot`,
`vendor_boot`, `dtbo`, `vbmeta`, `vbmeta_system` and `super`; never flash
`preloader`, `lk`, `tee`, `gz` or other firmware partitions. The Motorola
bootloader validates each image against the vbmeta currently on the device,
so flash `vbmeta` and `vbmeta_system` first.

Stock ships with only slot A populated (slot B has no bootloader), so flash
slot A explicitly and never switch slots.

Images keep the stock rollback index (7) and a boot/vendor security patch
level no lower than stock (2026-06-01).
