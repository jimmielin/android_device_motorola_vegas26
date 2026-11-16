#!/vendor/bin/sh
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Start the fingerprint HAL for whichever sensor this unit has fitted.
#
# vegas26 has an FPC sensor, but the stock vendor also supports Goodix. Each
# sensor needs its TEE driver module loaded before its HAL service starts,
# and the HAL reports a working sensor by setting
# vendor.hw.fingerprint.status=ok. The detected
# vendor is cached in /mnt/vendor/persist/fps/vendor_id (the same file stock
# firmware uses) so later boots try it first.

persist_id=/mnt/vendor/persist/fps/vendor_id

log() {
    echo "init.oem.fingerprint: $*" > /dev/kmsg
}

module_for() {
    case "$1" in
        fpc) echo fpc_mtk_tee.ko ;;
        goodix) echo goodix_fps_tee.ko ;;
    esac
}

service_for() {
    case "$1" in
        fpc) echo fps_hal ;;
        goodix) echo goodix_hal ;;
    esac
}

try_vendor() {
    module=$(module_for "$1")
    service=$(service_for "$1")

    setprop vendor.hw.fingerprint.status none
    setprop vendor.hw.fps.ident none
    insmod "/vendor/lib/modules/$module" || return 1
    sleep 1
    setprop vendor.hw.fps.ident "$1"
    start "$service"

    # Give the HAL up to three seconds to probe the sensor.
    for i in $(seq 1 30); do
        sleep 0.1
        [ "$(getprop vendor.hw.fingerprint.status)" != none ] && break
    done

    if [ "$(getprop vendor.hw.fingerprint.status)" = ok ]; then
        log "$1 sensor detected"
        setprop persist.vendor.hardware.fingerprint "$1"
        echo "$1" > "$persist_id"
        return 0
    fi

    log "$1 sensor not detected"
    stop "$service"
    rmmod "${module%.ko}"
    return 1
}

cached=$(cat "$persist_id" 2> /dev/null)
# Try the cached sensor first; FPC is the default probe order otherwise.
case "$cached" in
    goodix) order="goodix fpc" ;;
    *) order="fpc goodix" ;;
esac

for vendor in $order; do
    try_vendor "$vendor" && exit 0
done

log "no fingerprint sensor found"
setprop persist.vendor.hardware.fingerprint none
echo none > "$persist_id"
