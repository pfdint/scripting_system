#!/bin/bash
# scripting_system.sh
# by pfdint
# created: 2014-05-18
# modified: 2014-06-24
# purpose: the master ss executable. currently displays menus and stuff.
 
# If we want users to like our software we should design it to behave like a likeable person: respectful, generous, and helpful. - Alan Cooper
 
# Be respectful.
# Be generous.
# Be helpful.
 
set -o errexit
 
SS_Debug()
{
    
    echo ===
    echo $1
    echo ===
    
}

SS_Push_Category()
{
    
    SS_NEXT_ITEM="$1"
    SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER + 1 ))
    SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]="$SS_NEXT_ITEM"
    
}

SS_Pop_Category()
{
    
    unset SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]
    SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER - 1 ))
    SS_NEXT_ITEM="${SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]}"
    
}

SS_Compute_Target_Wrapper()
{
    
    SS_TARGET_WRAPPER="$SS_LIBRARY_DIRECTORY"
    local CATEGORY
    for CATEGORY in "${SS_CATEGORY_HISTORY[@]}"; do
        SS_TARGET_WRAPPER="${SS_TARGET_WRAPPER}/${CATEGORY}"
    done
    SS_TARGET_WRAPPER="${SS_TARGET_WRAPPER%/}.wrap"
    
}
 
SS_Display_Item()
{
    
    local IS_ITEM_CATEGORY=false
    
    local LINE
    for LINE in "${SS_CATEGORY_ARRAY[@]}"; do
        if [[ $LINE == "%$SS_NEXT_ITEM" ]]; then
            IS_ITEM_CATEGORY=true
            break
        fi
    done
 
    if [[ "$IS_ITEM_CATEGORY" == true ]]; then
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
        if [[ ${SS_CATEGORY_ARRAY[$LINE_INDEX]} =~ ^%$SS_NEXT_ITEM$ ]]; then
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
    
    # We will need the longest number and title for constructing a properly formatted menu.
    #
    local NUMBER_OF_ITEMS_IN_CATEGORY=${#CATEGORY_ITEMS[@]}
    local LONGEST_NUMBER_LENGTH=${#NUMBER_OF_ITEMS_IN_CATEGORY}
    
    # We do a loop to find the longest title. It doesn't matter what it is, we just need its length.
    #
    local TITLE
    for TITLE in "${CATEGORY_ITEM_TITLES[@]}"; do
        local TITLE_LENGTHS[${#TITLE}]="$TITLE"
    done
    
    local LONGEST_TITLE=${TITLE_LENGTHS[@]: -1}
    local LONGEST_WORD_LENGTH=${#LONGEST_TITLE}
    
    # Now we begin construction of the menu. <<<<<<<<<<<<<<<<<<<<<<
    
    echo
    echo
    echo ======================================================================
    echo ${SS_NEXT_ITEM:-scripting_system}
    echo ======================================================================
    echo
    
    local PERMANENT_PADDING=".........."
    local ITERATION
    
    # This is the loop which constructs each menu item.
    #
    local ITEM_NUMBER
    for ITEM_NUMBER in ${!CATEGORY_ITEMS[@]}; do
        
        unset NUMBER_PADDING
        unset TITLE_PADDING
        
        local SELECTION_NUMBER=$(( $ITEM_NUMBER + 1 ))
        local ITEM_TITLE=${CATEGORY_ITEM_TITLES[$ITEM_NUMBER]}
        
        for (( ITERATION=0; ITERATION < $LONGEST_NUMBER_LENGTH - ${#SELECTION_NUMBER}; ITERATION++ )); do
            NUMBER_PADDING="${NUMBER_PADDING} "
        done
        
        for (( ITERATION=0; ITERATION < $LONGEST_WORD_LENGTH - ${#ITEM_TITLE}; ITERATION++ )); do
            TITLE_PADDING="${TITLE_PADDING}."
        done
        
        echo "${SS_INDENT}${SELECTION_NUMBER}${NUMBER_PADDING} - ${CATEGORY_ITEM_TITLES[$ITEM_NUMBER]} ${TITLE_PADDING}${PERMANENT_PADDING} ${CATEGORY_ITEM_DESCRIPTIONS[$ITEM_NUMBER]}"
        
    done
    
    echo "${SS_INDENT}----"
    echo "${SS_INDENT}!  - run most recent script"
    echo "${SS_INDENT}p  - return to previous menu"
    echo "${SS_INDENT}q  - quit"
    echo
    
    local SELECTION
    read -p "Select an option: " SELECTION
    
    #PURPOSEFUL STRING COMPARISON; NOT INTEGER COMPARISON
    if [[ "$SELECTION" == "0" ]]; then
        :
    elif [[ $SELECTION =~ ^[[:digit:]]+$ ]]; then
        if [[ $SELECTION -le ${#CATEGORY_ITEMS[@]} ]]; then
            SS_Push_Category "${CATEGORY_ITEM_TITLES[$SELECTION - 1]}"
        else
            echo "Not a valid selection for this menu."
        fi
    elif [[ "$SELECTION" =~ ^[!pq]$ ]]; then
            case "$SELECTION" in
                !)
                    echo -n "NYI"
                    ;;
                p)
                    SS_Pop_Category
                    ;;
                q)
                    SS_IS_DISPLAYING_MENUS=false
                    exit 0
                    ;;
            esac
    else
        echo "That input was completely invalid."
    fi
    
}
 
SS_Display_Script()
{
    
    SS_Compute_Target_Wrapper
    
    echo
    echo
    echo ======================================================================
    echo $SS_NEXT_ITEM
    echo ======================================================================
    echo
    echo "${SS_INDENT}r  - run"
    echo "${SS_INDENT}e  - edit"
    echo "${SS_INDENT}w  - edit wrapper file"
    echo "${SS_INDENT}b  - run & return               (background)"
    echo "${SS_INDENT}v  - edit & return              (view)"
    echo "${SS_INDENT}m  - edit wrapper file & return (modify)"
    echo "${SS_INDENT}----"
    echo "${SS_INDENT}p  - return to previous menu"
    echo "${SS_INDENT}q  - quit"
    echo
    
    local SELECTION
    read -p "Select an option: " SELECTION
 
    case "$SELECTION" in
        r)
            SS_IS_DISPLAYING_MENUS=false
            SS_Execute_Wrapper
            ;;
        e)
            SS_IS_DISPLAYING_MENUS=false
            $EDITOR "$SS_SCRIPT_LOCATION"
            ;;
        w)
            SS_IS_DISPLAYING_MENUS=false
            $EDITOR "$SS_TARGET_WRAPPER"
            ;;
        b)
            SS_Execute_Wrapper
            ;;
        v)
            $EDITOR "$SS_SCRIPT_LOCATION"
            ;;
        m)
            $EDITOR "$SS_TARGET_WRAPPER"
            ;;
        p)
            SS_Pop_Category
            ;;
        q)
            SS_IS_DISPLAYING_MENUS=false
            exit 0
            ;;
        *)
            echo "That input was invalid."
            ;;
    esac
    
}
 
SS_Execute_Wrapper()
{
    
    SS_Parse_Wrapper
    
    SS_Check_Dependencies
    
    if [[ "$SS_IS_MISSING_DEPENDENCIES" == true ]]; then
        return 0
    fi
    
    if [[ "$SS_USE_MOLLYGUARD" == true ]]; then
        echo
        echo $SS_MOLLYGUARD_MESSAGE
    fi
    
    SS_Query_For_Options
    
    local FINAL_ANSWER
    echo "The following command will be executed."
    echo ${SS_FINAL_COMMAND}
    echo "Is this okay? [y/N] "
    read FINAL_ANSWER
    
    if [[ "$FINAL_ANSWER" == "y" ]]; then
        echo okay then!
    else
        echo "### Execution cancelled. ###"
        return 0
    fi
    
    #Mollyguard
    echo mollyguard goes here
    
}
 
SS_Check_Dependencies()
{
    
    local -A MISSING_DEPENDENCIES
    
    local FILE_TO_CHECK
    for FILE_TO_CHECK in "${SS_DEPENDENCIES[@]}"; do
        if [[ ! -e $FILE_TO_CHECK ]]; then
            MISSING_DEPENDENCIES[$FILE_TO_CHECK]="$FILE_TO_CHECK"
        fi
    done
     
    if [[ ${#MISSING_DEPENDENCIES[@]} -gt 0 ]]; then
        SS_IS_MISSING_DEPENDENCIES=true
        local MISSING_FILE
        for MISSING_FILE in "${MISSING_DEPENDENCIES[@]}"; do
            echo "Dependency not satisfied: $MISSING_FILE is missing."
        done
    fi
     
}

SS_Query_For_Options()
{
    
    local COMMAND
    local INPUT_ARGUMENT
    local KEY
    for KEY in "${!SS_OPTIONS[@]}"; do
        echo -en "${SS_OPTIONS[$KEY]%%::*}"
        if [[ "${SS_OPTIONS[$KEY]}" =~ .*::.* ]]; then
            read INPUT_ARGUMENT
            local DEFAULT_VALUE="${SS_OPTIONS[$KEY]##*::}"
            COMMAND="${COMMAND} ${KEY} ${INPUT_ARGUMENT:-${DEFAULT_VALUE}}"
        else
            read -p "[y/N] " INPUT_ARGUMENT
            if [[ "$INPUT_ARGUMENT" =~ [Yy]|Yes ]]; then
                COMMAND="${COMMAND} ${KEY}"
            fi
        fi
    done
#        echo -e "${SS_OPTIONS[$KEY]%%::*}"
#        read INPUT_ARGUMENT
#        local DEFAULT_VALUE="${SS_OPTIONS[$KEY]##*::}"
#        COMMAND="${COMMAND} ${KEY} ${INPUT_ARGUMENT:-$DEFAULT_VALUE}"
#    done
    SS_FINAL_COMMAND="${SS_SCRIPT_LOCATION}${COMMAND}"
    
}
 
SS_Parse_Wrapper()
{
    
    local RAW_WRAPPER_FILE_ARRAY
    
    mapfile -t RAW_WRAPPER_FILE_ARRAY < "$SS_TARGET_WRAPPER"
    
    local DEPENDENCY_COUNT
    local OPTION_KEY
    
    local RAW_LINE
    for RAW_LINE in "${RAW_WRAPPER_FILE_ARRAY[@]}"; do
        if [[ !($RAW_LINE =~ ^#.*) ]] && [[ !($RAW_LINE =~ ^$) ]]; then
            if [[ ${RAW_LINE%%=*} == "location" ]]; then
                SS_SCRIPT_LOCATION="${RAW_LINE##*=}"
            elif [[ ${RAW_LINE%%=*} == "dependency" ]]; then
                DEPENDENCY_COUNT=$(( $DEPENDENCY_COUNT + 1 ))
                SS_DEPENDENCIES[$DEPENDENCY_COUNT]="${RAW_LINE##*=}"
            elif [[ $RAW_LINE =~ option_* ]]; then
                OPTION_KEY=${RAW_LINE%%=*}
                OPTION_KEY=${OPTION_KEY//option_/}
                SS_OPTIONS[$OPTION_KEY]=${RAW_LINE##*=}
            elif [[ $RAW_LINE == mollyguard* ]]; then
                SS_USE_MOLLYGUARD=true
                SS_MOLLYGUARD_MESSAGE=${RAW_LINE##*::}
            fi
        fi
    done
    
}
 
SS_Read_Categories_File()
{
    
    local RAW_CATEGORY_FILE_ARRAY
    
    mapfile -t RAW_CATEGORY_FILE_ARRAY < ss_category_config
    
    local INDEX_IN_TARGET=0
    
    local RAW_LINE
    for RAW_LINE in "${RAW_CATEGORY_FILE_ARRAY[@]}"; do
        if [[ !($RAW_LINE =~ ^#.*) ]] && [[ !($RAW_LINE =~ ^$) ]]; then
            SS_CATEGORY_ARRAY[$INDEX_IN_TARGET]="$RAW_LINE"
            INDEX_IN_TARGET=$(( $INDEX_IN_TARGET + 1 ))
        fi
    done
    
}
 
SS_INDENT="    "
SS_LIBRARY_DIRECTORY="library"
SS_IS_MISSING_DEPENDENCIES=false
declare -A SS_OPTIONS
 
if [[ -z $EDITOR ]]; then
    EDITOR="vim"
fi
 
SS_Read_Categories_File
 
SS_IS_DISPLAYING_MENUS=true
while [[ "$SS_IS_DISPLAYING_MENUS" == true ]]; do
#    printf "\033c"
    SS_Display_Item
done
