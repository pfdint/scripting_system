#!/bin/bash
# migrate_scripts.sh
# by pfdint
# created: 2014-06-29
# modified: 
# purpose: to copy all scripts currently in the scripting system into the ss library

if ! [[ -e library ]]; then
    echo Only run me from the ss home directory.
    exit 1
fi

for file in $(find ./library -name \*.wrap -print); do
    remote="$(grep 'location' "$file")"
    remote="${remote##location=}"
    cp "$remote" "${file%wrap}sh"
    echo "Copied $remote to ${file%wrap}sh"
    sed -i "/$remote/${file%wrap}sh/" "$file"
done
