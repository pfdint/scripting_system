#!/bin/bash
# new_user.sh
# by pfdint
# created: 2014-06-29
# modified:
# purpose: to adapt sample ss scripts to a new user home directory.

if ! [[ -e library ]]; then
    echo "Only execute me from the ss home directory."
    exit 1
fi

originalUser="pfdint"
newUser="$(whoami)"

while getopts ":o:n:" OPTION; do
    case $OPTION in
        o)  originalUser="$OPTARG";;
        n)  newUser="$OPTARG";;
    esac
done

echo "Changing $originalUser to $newUser"

for file in $(find ./library -name \*.wrap -print); do
    sed -i "s/$originalUser/$newUser/g" "$file"
done
