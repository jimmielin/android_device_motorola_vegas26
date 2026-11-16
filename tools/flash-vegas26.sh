#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Flash a LineageOS release for the moto g power - 2026 (XT2617V, vegas26)
# from the bootloader, to slot A only. Run it from the directory holding the
# images, with the phone in bootloader fastboot mode.
#
# 1. In the bootloader: check that this is an XT2617V on slot A running the
#    stock firmware the release was built against, then flash vbmeta first
#    (Motorola's bootloader validates every image against the vbmeta on the
#    device), then boot, init_boot, vendor_boot and dtbo.
# 2. Reboot to fastbootd (the LineageOS recovery just flashed), reset the
#    super partition layout and flash the logical partitions to slot A.
#
# It never flashes bootloader or firmware partitions and never changes the
# active slot. Every step stops on failure; re-running it is safe.
# It never wipes data: formatting data (required when coming from stock or
# another ROM) is left to the user, as is installing Google apps.
set -euo pipefail
cd "$(dirname "$0")"

FIRMWARE=W1WEOS36.48-22-3-3-4-3

getvar() { fastboot getvar "$1" 2>&1 | awk -v k="$1:" '$1 == k || $2 == k {print $NF}' | head -1; }
need() { [ -s "$1" ] || { echo "ABORT: missing $1"; exit 1; }; }

for f in vbmeta vbmeta_system boot init_boot vendor_boot dtbo super_empty \
         system system_ext product vendor vendor_dlkm; do
    need "$f.img"
done
if [ -f SHA256SUMS ]; then
    sha256sum -c --quiet SHA256SUMS || { echo "ABORT: image checksums do not match"; exit 1; }
fi

echo "== Checking the phone (bootloader)"
[ "$(getvar is-userspace)" = no ] || { echo "ABORT: put the phone in bootloader fastboot mode"; exit 1; }
[ "$(getvar sku)" = XT2617V ] || { echo "ABORT: not an XT2617V"; exit 1; }
[ "$(getvar current-slot)" = a ] || { echo "ABORT: the phone is not on slot A"; exit 1; }
bl=$(fastboot getvar version-bootloader 2>&1 | grep -o 'version-bootloader[^:]*: .*' \
    | sed 's/^[^:]*: //' | tr -d '\r\n')
case "$bl" in
    *"$FIRMWARE"*) ;;
    *) echo "ABORT: bootloader is not from stock $FIRMWARE: $bl"
       echo "This release only supports phones on that firmware."; exit 1 ;;
esac

echo "== Flashing boot images to slot A"
fastboot flash vbmeta_a vbmeta.img
fastboot flash vbmeta_system_a vbmeta_system.img
fastboot flash boot_a boot.img
fastboot flash init_boot_a init_boot.img
fastboot flash vendor_boot_a vendor_boot.img
fastboot flash dtbo_a dtbo.img

echo "== Rebooting to fastbootd"
fastboot reboot fastboot
for _ in $(seq 1 60); do
    [ "$(getvar is-userspace 2>/dev/null)" = yes ] && break
    sleep 2
done
[ "$(getvar is-userspace)" = yes ] || { echo "ABORT: fastbootd did not come up"; exit 1; }
[ "$(getvar current-slot)" = a ] || { echo "ABORT: fastbootd is not on slot A"; exit 1; }

echo "== Flashing logical partitions to slot A"
fastboot wipe-super super_empty.img
for p in system system_ext product vendor vendor_dlkm; do
    fastboot flash "$p" "$p.img"
done

echo
echo "Done. The phone is in fastbootd. Before the first boot:"
echo
echo " - Coming from stock or another ROM? Format data now; LineageOS cannot use"
echo "   stock's encrypted data, and this erases everything on the phone:"
echo "     fastboot -w"
echo "   Skip this when updating an existing install of these builds."
echo " - Want Google apps? Install MindTheGapps for Android 16 (arm64) before the"
echo "   first boot (https://github.com/MindTheGapps/16.0.0-arm64/releases):"
echo "     fastboot reboot recovery"
echo "     then Apply update > Apply from ADB, and: adb sideload MindTheGapps-16.0.0-arm64-*.zip"
echo
echo "Then reboot:  fastboot reboot   (or Reboot system now, from recovery)"
