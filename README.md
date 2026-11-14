# Device tree for moto g power - 2025 (vegas)

LineageOS 23.2 device tree for the Motorola moto g power - 2025
(XT2515, codename `vegas`), built on `device/motorola/mt6835-common`.

| | |
|---|---|
| SoC | MediaTek MT6835 (Dimensity 6300): 2x Cortex-A76 + 6x Cortex-A55, Mali-G57 MC2 |
| Kernel | Google GKI 5.15 (android13-5.15), prebuilt from stock (`vegas-kernels`) |
| Display | 1080x2388, 120 Hz (Novatek or Ilitek touch) |
| Cameras | 50 MP OV50D, 8 MP OV08D ultrawide, 16 MP S5K3P9 front |
| Fingerprint | Goodix or FPC, side-mounted in the power key |
| NFC | NXP SN220 (AOSP NXP HAL from `hardware/nxp/nfc`) |
| Audio | MT6377 codec, AWINIC aw883xx amplifier |
| Storage / partitions | UFS, Virtual A/B with compression, `init_boot`, super 10166992896 bytes |

## Building

```sh
source build/envsetup.sh
lunch lineage_vegas-bp4a-userdebug
m bacon superimage
```

Proprietary files come from stock `W1VES36H.10-12-9-8-4`; regenerate them with
`./extract-files.py <dump>` against a dump of that build (partition-root
layout: `vendor/`, `system/`, `system_ext/`, `product/`, ...).

## Flashing safety

This device has no known BROM rescue path: a damaged bootloader chain is a
permanent brick. Builds only ever produce and flash `boot`, `init_boot`,
`vendor_boot`, `dtbo`, `vbmeta`, `vbmeta_system` and `super`; never flash
`preloader`, `lk`, `tee`, `gz` or other firmware partitions. The Motorola
bootloader validates each image against the vbmeta currently on the device,
so flash `vbmeta` and `vbmeta_system` first.

Images keep the stock rollback index (21) and a boot/vendor security patch
level no lower than stock (2026-08-01).
