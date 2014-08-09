#!/bin/bash
# new_script.sh
# by pfdint
# created: 2014-07-20
# modified: 
# purpose: creates a file and fills it with a template according to environment,
#  for new bash scripts

if [[ $# -lt 1 ]]; then
    echo "Provide the script name as an argument."
    exit 1
fi

SCRIPT_NAME="$1"

PREFIX="# "

BASH_HEADER="#!/bin/bash"
FILENAME="${SCRIPT_NAME##*/}"
USER="by `whoami`"
CREATION_DATE="created: `date +%Y-%m-%d`"
MODIFIED="modified: "
PURPOSE="purpose: "

echo $BASH_HEADER > $SCRIPT_NAME
echo "${PREFIX}${FILENAME}" >> $SCRIPT_NAME
echo "${PREFIX}${USER}" >> $SCRIPT_NAME
echo "${PREFIX}${CREATION_DATE}" >> $SCRIPT_NAME
echo "${PREFIX}${MODIFIED}" >> $SCRIPT_NAME
echo "${PREFIX}${PURPOSE}" >> $SCRIPT_NAME

chmod u+x "$SCRIPT_NAME"

vim "$SCRIPT_NAME"
