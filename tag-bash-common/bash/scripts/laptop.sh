#!/usr/bin/env bash

# {{{ Vars
ACPI="/sys/devices/platform/thinkpad_acpi"
BAT="/sys/devices/platform/smapi/BAT0"
BL="/sys/class/backlight/intel_backlight/brightness"
BT="${ACPI}/bluetooth_enable"
# }}}

# {{{ Network
alias wol2="wol 40:61:86:87:F3:FE"
alias wol2i="wol -i 192.168.0.2 40:61:86:87:F3:FE"
alias ssh2="$SSH2"
alias ping2="ping 192.168.0.2"
# }}}

# {{{ Display
if have backlight; then
    alias bl=backlight
fi
doff() {
    local cmd
    [[ -n "$1" ]] && cmd="$SSH2 DISPLAY=:0 "
    cmd+="xset dpms force off"
    eval ${cmd}
}
don() {
    local cmd
    [[ -n "$1" ]] && cmd="$SSH2 DISPLAY=:0 "
    cmd+="xset dpms force on"
    eval ${cmd}
}
# }}}



