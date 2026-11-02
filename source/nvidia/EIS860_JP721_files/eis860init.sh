#!/bin/bash
# Hub0 shares USB0 with the flashing connector. Only run in normal rootfs boot.
eis860_usb_host_init() (
    local role=/sys/class/usb_role/usb2-0-role-switch/role
    local hub=/sys/bus/usb/devices/1-1
    local attempt restore_host=0

    usb_log() { printf '[eis860-usb] %s\n' "$*"; }
    hub_ready() {
        [[ -r "$hub/idVendor" && -r "$hub/idProduct" ]] &&
            [[ "$(cat "$hub/idVendor")" == 0451 &&
               "$(cat "$hub/idProduct")" == 8027 ]]
    }
    wait_hub() {
        local second
        for ((second=0; second<$1; second++)); do
            hub_ready && return 0
            sleep 1
        done
        hub_ready
    }
    trap 'if ((restore_host)); then echo host > "$role"; fi' EXIT

    for ((attempt=0; attempt<10; attempt++)); do
        [[ -w "$role" ]] && break
        sleep 1
    done
    if [[ ! -w "$role" ]]; then
        usb_log 'ERROR: USB0 role node unavailable after 10 seconds'
        return 1
    fi
    if ! echo host > "$role"; then
        usb_log 'ERROR: cannot set USB0 to host'
        return 1
    fi
    if wait_hub 5; then
        usb_log 'Hub0 ready; no recovery needed'
        return 0
    fi
    # Never disconnect an already enumerated, unexpected device on USB0.
    if [[ -e "$hub" ]]; then
        usb_log 'ERROR: unexpected device at 1-1; skipping recovery'
        return 1
    fi
    usb_log 'Hub0 absent; attempting one USB0 none -> host recovery'
    restore_host=1
    if ! echo none > "$role"; then
        usb_log 'ERROR: cannot set USB0 to none'
        return 1
    fi
    sleep 2
    if ! echo host > "$role"; then
        usb_log 'ERROR: cannot restore USB0 host role'
        return 1
    fi
    restore_host=0
    if wait_hub 8; then
        usb_log 'Hub0 recovered successfully'
        return 0
    fi
    usb_log 'ERROR: Hub0 still absent; no further retries this invocation'
    return 1
)

# USB failure must not prevent the other board startup tasks.
eis860_usb_host_init || echo '[eis860-usb] WARNING: continuing board startup with USB failure'
iptables -I INPUT -p tcp --dport 111 -j DROP
iptables -I INPUT -p udp --dport 111 -j DROP
/opt/tools/EIS860_Get_CPU_temp/pythoninstall.sh
/opt/tools/EIS860_Get_CPU_temp/EIS860_Set_Cpu_temp.sh 2>&1 &
/opt/tools/EIS860_Get_CPU_temp/NetLight.sh
