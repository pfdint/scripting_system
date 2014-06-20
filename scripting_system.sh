#!/bin/bash
# scripting_system.sh
# by pfdint
# created: 2014-05-18
# modified: 2014-06-19
# purpose: the master ss executable. currently displays menus and stuff.

set -o errexit

SS_Go_Next_Category()
{
    
    # Rename arguments
    #
    local NEXT_CATEGORY="$1"
    
    SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER + 1 ))
    
    SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]="$NEXT_CATEGORY"
    
    SS_NEXT_CATEGORY="$NEXT_CATEGORY"
    
}

SS_Go_Previous_Category()
{
    
    unset SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]
    SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER - 1 ))
    SS_NEXT_CATEGORY="${SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]}"
    
}

SS_Read_Categories_File()
{
    
    mapfile -t SS_RAW_CATEGORY_ARRAY_FILE < ss_category_config
    
    local RAW_LINE
    local INDEX=0
    
    for RAW_LINE in "${SS_RAW_CATEGORY_ARRAY_FILE[@]}"; do
        if [[ !($RAW_LINE =~ ^#.*) ]] && [[ !($RAW_LINE =~ ^$) ]]; then
            SS_CATEGORY_ARRAY[$INDEX]="$RAW_LINE"
            INDEX=$(( $INDEX + 1 ))
        fi
    done
    
#    mapfile -t SS_CATEGORY_ARRAY < categories.config
    
}

# Globals used: $SS_IS_ITEM_CATEGORY
# $SS_CATEGORY_ARRAY
# Takes a category name, flips the boolean true if it's a category, false if not.
#
SS_Determine_If_Category()
{
    
    # We assume false for safety.
    #
    SS_IS_ITEM_CATEGORY=false
    
    local SS_LINE
    
    for SS_LINE in "${SS_CATEGORY_ARRAY[@]}"; do
        if [[ $SS_LINE == "%$SS_NEXT_CATEGORY" ]]; then
            SS_IS_ITEM_CATEGORY=true
            break
        fi
    done
    
}

SS_Display_Script()
{
    echo -n "NYI"
}

SS_Display_Item()
{
    
    SS_Determine_If_Category
    
    if [[ "$SS_IS_ITEM_CATEGORY" == true ]]; then
        SS_Display_Category
    else
        SS_Display_Script
    fi
    
}

SS_Display_Category()
{
    
    local START_LINE=0
    local END_LINE=${#SS_CATEGORY_ARRAY[@]}
    local FOUND_NEXT_CATEGORY=false
    
    local LINE_INDEX
    for (( LINE_INDEX=0; LINE_INDEX < ${#SS_CATEGORY_ARRAY[@]}; LINE_INDEX++ )); do
        if [[ ${SS_CATEGORY_ARRAY[$LINE_INDEX]} =~ ^%$SS_NEXT_CATEGORY$ ]]; then
            START_LINE=$LINE_INDEX
            FOUND_NEXT_CATEGORY=true
        elif [[ "$FOUND_NEXT_CATEGORY" == true ]] && [[ ${SS_CATEGORY_ARRAY[$LINE_INDEX]} =~ ^%.+ ]]; then
            END_LINE=$LINE_INDEX
            break
        fi
    done
    
    START_LINE=$(( $START_LINE + 1 ))
    local DISTANCE=$(( $END_LINE - $START_LINE ))
    
    local CATEGORY_ITEMS=( "${SS_CATEGORY_ARRAY[@]:$START_LINE:$DISTANCE}" )
    
    local CATEGORY_ITEM_TITLES=( "${CATEGORY_ITEMS[@]%%::*}" )
    local CATEGORY_ITEM_DESCRIPTIONS=( "${CATEGORY_ITEMS[@]##*::}" )
    
    local CATEGORY_ITEMS_SIZE=${#CATEGORY_ITEMS[@]}
    local SIZE_NUMBER_LENGTH=${#CATEGORY_ITEMS_SIZE}
    
    local TITLE
    
    for TITLE in "${CATEGORY_ITEM_TITLES[@]}"; do
        local TITLE_LENGTHS[${#TITLE}]="$TITLE"
    done
    
    local LONGEST_WORD=${TITLE_LENGTHS[@]: -1}
    local LONGEST_WORD_SIZE=${#LONGEST_WORD}
    
    echo
    echo
    echo ===========================================================
    echo $SS_NEXT_CATEGORY
    echo ===========================================================
    echo
    
    local PERMANENT_PADDING=".........."
    
    local ITEM_NUMBER
    
    for ITEM_NUMBER in ${!CATEGORY_ITEMS[@]}; do
        local IDENTIFICATION_NUMBER=$(( $ITEM_NUMBER + 1 ))
        local ITEM_TITLE=${CATEGORY_ITEM_TITLES[$ITEM_NUMBER]}
        
        unset IDENTIFIER
        
        local ITERATION
        for (( ITERATION=0; ITERATION < $SIZE_NUMBER_LENGTH - ${#IDENTIFICATION_NUMBER}; ITERATION++ )); do
            IDENTIFIER="$IDENTIFIER "
        done
        
        IDENTIFIER="$IDENTIFICATION_NUMBER$IDENTIFIER - "
        
        local PADDING_SIZE=$(( ${LONGEST_WORD_SIZE} - ${#ITEM_TITLE} ))
        
        unset PADDING
        
        for (( ITERATION=0; ITERATION < $PADDING_SIZE; ITERATION++ )); do
            PADDING="${PADDING}."
        done
        
        local INDENT="    "

        echo "$INDENT$IDENTIFIER${CATEGORY_ITEM_TITLES[$ITEM_NUMBER]} $PADDING$PERMANENT_PADDING ${CATEGORY_ITEM_DESCRIPTIONS[$ITEM_NUMBER]}"
    done
    
    echo
    echo "$INDENT----"
    echo "${INDENT}p  - return to previous menu"
    echo "${INDENT}q  - quit"
    echo
    
    read -p "Select an option: " SELECTION
    
    #PURPOSEFUL STRING COMPARISON; NOT INTEGER COMPARISON
    if [[ "$SELECTION" == "0" ]]; then
        SS_NEXT_CATEGORY=$ITEM_TITLE
        echo will redisplay ourselves, do not push to stack
    elif [[ $SELECTION =~ ^[[:digit:]]+$ ]]; then
        if [[ $SELECTION -le ${#CATEGORY_ITEMS[@]} ]]; then
            echo ${CATEGORY_ITEM_TITLES[$SELECTION - 1]} will be the next menu
            SS_Go_Next_Category "${CATEGORY_ITEM_TITLES[$SELECTION - 1]}"
        else
            echo not a valid selection for this menu
        fi
        elif [[ "$SELECTION" =~ ^[pq]$ ]]; then
            case "$SELECTION" in
                p)
                    SS_Go_Previous_Category
                    ;;
                q)
                    SS_IS_DISPLAYING_MENUS=false
                    exit 0
                    ;;
            esac
        else
            echo that was not valid input and you know it
        fi
    
}

SS_Read_Categories_File
SS_IS_DISPLAYING_MENUS=true
while [[ "$SS_IS_DISPLAYING_MENUS" == true ]]; do
    SS_Display_Item "$SS_NEXT_CATEGORY"
done
