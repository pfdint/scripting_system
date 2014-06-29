#!/bin/bash
# voicetimer.sh
# by pfdint
# created: 2013-04-24
# modified: 2014-06-29
# Used to announce running times

while getopts "i:" OPTION; do
    case $OPTION in
        i)  interval="$OPTARG";;
    esac
done

if ! [[ $interval =~ ^[[:digit:]]+$ ]]; then
    echo "No interval specified, defaulting to five minutes."
    interval=5
fi

minute=0

while true; do
    if [ $(($minute % $interval)) -eq 0 ]; then
        espeak -p 25 "$minute minutes" 2>/dev/null
    fi
    minute=$(( $minute + 1 ))
    sleep 60
done
