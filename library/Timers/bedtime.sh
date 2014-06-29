#!/bin/bash
# bedtime.sh
# by pfdint
# created: 2013-04-14
# modified: 2014-06-29
# Used to make sure you don't play Minecraft past a certain time.

# Specify a command to execute inside the action function, if you like.
action()
{
    :
}

while getopts "t:" OPTION; do
    case $OPTION in
        t)  bedtime="$OPTARG";;
    esac
done

if ! [[ $bedtime =~ ^[[:digit:]]{4}$ ]]; then
    echo "No or invalid bedtime specified."
    exit 1
fi

checking=true

espeak -s 150 -p 25 -a 150 "Countdown initiated." 2>/dev/null

while $checking ; do
    if [ $bedtime -eq `date +%H%M --date '+120 min'` ]; then
        espeak -s 150 -p 25 -a 150 "Two hours remaining." 2>/dev/null
    elif [ $bedtime -eq `date +%H%M --date '+60 min'` ]; then
        espeak -s 150 -p 25 -a 150 "One hour remaining." 2>/dev/null
        espeak -s 150 -p 30 -a 150 -g 15 "One hour remaining."
    elif [ $bedtime -eq `date +%H%M --date '+30 min'` ]; then
        espeak -s 150 -p 25 -a 150 "Thirty minutes" 2>/dev/null
    elif [ $bedtime -eq `date +%H%M --date '+15 min'` ]; then
        espeak -s 150 -p 30 -a 150 "Fifteen minutes" 2>/dev/null
        espeak -s 125 -p 30 -a 150 -g 15 "Fifteen minutes"
    elif [ $bedtime -eq `date +%H%M --date '+10 min'` ]; then
        espeak -s 150 -p 25 -a 150 "Ten minutes" 2>/dev/null
    elif [ $bedtime -eq `date +%H%M --date '+5 min'` ]; then
        espeak -s 175 -p 25 -a 150 "Five minutes remain" 2>/dev/null
        espeak -s 175 -p 30 -a 150 -g 15 "Five minutes remain" 2>/dev/null
    elif [ $bedtime -eq `date +%H%M --date '+1 min'` ]; then
        espeak -p 30 -a 200 "Sixty seconds remaining." 2>/dev/null
    elif [ $bedtime -eq `date +%H%M` ]; then
        espeak -s 150 -p 30 -a 150 "Time is up. Time is up. Cease and desist." 2>/dev/null
        action
        checking=false
        exit 0
    fi
    sleep 55
done
