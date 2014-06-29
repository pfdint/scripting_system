#!/bin/bash
# graphics.sh
# by pfdint
# created:26-01-2013
# modified:
# Reads, turns on and off graphics card.
# Depends on bbswitch.
# Must be run as root to change on/off state.

# This function checks if run as root and prints reminder as necessary.
verify()
{
    if [ $USER != "root" ]; then
        echo "Must run as root to change state."
        exit
    fi
}

switchdir="/proc/acpi/bbswitch"

case $1 in
    "off"    ) verify; tee $switchdir <<<OFF; cat $switchdir;;
    "on"    ) verify; tee $switchdir <<<ON; cat $switchdir;;
    *    ) cat $switchdir;;
esac
