#!/bin/bash
# scripting_system.sh
# by pfdint
# created: 2014-05-18
# modified: 2014-06-29
# purpose: the master ss executable. currently displays menus and stuff.
 
# If we want users to like our software we should design it to behave like a likeable person: respectful, generous, and helpful. - Alan Cooper
 
# Be respectful.
# Be generous.
# Be helpful.

#TODO:
#   Static (command line) execution using options
#   Option menus
#   Implement common functionality
#   Create obfuscator (internal)
#   Create adapter scripts
 
# Globals currently in use:
# IFS
# EDITOR
# SS_RC_SUCCESS
# SS_RC_FAILURE
# SS_WORKING_DIRECTORY
# SS_CATEGORY_FILE
# SS_INDENT
# SS_LIBRARY_DIRECTORY
# SS_IS_DISPLAYING_MENUS
# SS_NEXT_ITEM
# SS_PAGE_NUMBER
# SS_CATEGORY_HISTORY (a)
# SS_TARGET_WRAPPER
# SS_FINAL_COMMAND
# SS_SCRIPT_LOCATION
# SS_DEPENDENCIES (a)
# SS_OPTIONS (A)
# SS_USE_MOLLYGUARD
# SS_MOLLYGUARD_MESSAGE
# SS_CATEGORY_ARRAY (a)
# SS_STATIC_SELECTION
# SS_ACKNOWLEDGE_MOLLYGUARD <<Still not in use
 
SS_Debug()
{
    
    echo ===
    echo $1
    echo ===
    
}

####################################################################
# SS_Take_Own_Options
#
#   This is where getopts is called and options override default
#   values for the respective globals.
#
#   Globals used (m is modified):
#     m OPTARG
#     m SS_CATEGORY_FILE
#     m SS_LIBRARY_DIRECTORY
#     m SS_STATIC_SELECTION
#     m SS_ACKNOWLEDGE_MOLLYGUARD
#
####################################################################
#
SS_Take_Own_Options()
{
    
    local OPTION
    while getopts "c:l:s:m" OPTION; do
        case $OPTION in
            c)
                SS_CATEGORY_FILE="$OPTARG"
                ;;
            l)
                SS_LIBRARY_DIRECTORY="$OPTARG"
                ;;
            s)
                SS_STATIC_SELECTION="$OPTARG"
                ;;
            m)
                SS_ACKNOWLEDGE_MOLLYGUARD=true
                ;;
            *)
                echo "$OPTION is unrecognized option."
                ;;
        esac
    done
    
}

####################################################################
# SS_Initialize
#
#   Initilizes globals which need to be set prior to execution.
#
#   Globals used (m is modified):
#     m SS_WORKING_DIRECTORY
#     m SS_RC_SUCCESS
#     m SS_RC_FAILURE
#     m SS_CATEGORY_FILE
#     m SS_INDENT
#     m SS_LIBRARY_DIRECTORY
#     m SS_OPTIONS
#
####################################################################
#
SS_Initialize()
{
    
    SS_WORKING_DIRECTORY="${0%/*}/"
    
    SS_RC_SUCCESS=0
    SS_RC_FAILURE=1
    
    SS_CATEGORY_FILE="${SS_WORKING_DIRECTORY}ss_category_config"
    
    SS_INDENT="    "
    
    SS_LIBRARY_DIRECTORY="${SS_WORKING_DIRECTORY}library"
    
    declare -Ag SS_OPTIONS
    
}

####################################################################
# SS_Edit_File
#
#   arg1 = The file to edit.
#   
#   Figures out the editor and edits the file, or exits if there
#   is no editor.
#
#   Globals used (m is modified):
#     m EDITOR
#       
####################################################################
#
SS_Edit_File()
{
    
    # Rename arguments
    #
    local FILE_TO_EDIT="$1"
    
    if [[ -z "$EDITOR" ]]; then
        EDITOR="vim"
        echo "No editor specified or \$EDITOR not marked for export. Using ${EDITOR}."
    fi
    
    if SS_Has_Own_Dependencies "$EDITOR"; then
        $EDITOR "$FILE_TO_EDIT"
    else
        echo "Editor $EDITOR not available. Unable to edit file."
    fi
    
}

####################################################################
# SS_Push_Category
#
#   arg1 = The item to push on to the category history stack.
#
#   Pushes responsibly on to the category history stack. Said stack
#   should only be modified through this function (or pop).
#
#   Globals used (m is modified):
#     m SS_NEXT_ITEM
#     m SS_PAGE_NUMBER
#     m SS_CATEGORY_HISTORY
#
####################################################################
#
SS_Push_Category()
{
    
    SS_NEXT_ITEM="$1"
    SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER + 1 ))
    SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]="$SS_NEXT_ITEM"
    
}

####################################################################
# SS_Pop_Category
#
#   Pops the top off the category history stack, destroying the datum.
#
#   Globals used (m is modified):
#     m SS_NEXT_ITEM
#     m SS_PAGE_NUMBER
#     m SS_CATEGORY_HISTORY
#
####################################################################
#
SS_Pop_Category()
{
    
    unset SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]
    SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER - 1 ))
    SS_NEXT_ITEM="${SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]}"
    
}

####################################################################
# SS_Compute_Target_Wrapper
#
#   Flattens the current category history stack to create and fill
#   SS_TARGET_WRAPPER
#
#   Globals used (m is modified):
#     m SS_TARGET_WRAPPER
#       SS_CATEGORY_HISTORY
#
####################################################################
#
SS_Compute_Target_Wrapper()
{
    
    SS_TARGET_WRAPPER="$SS_LIBRARY_DIRECTORY"
    local CATEGORY
    for CATEGORY in "${SS_CATEGORY_HISTORY[@]}"; do
        SS_TARGET_WRAPPER="${SS_TARGET_WRAPPER}/${CATEGORY}"
    done
    SS_TARGET_WRAPPER="${SS_TARGET_WRAPPER%/}.wrap"
    
}

####################################################################
# SS_Has_Own_Dependencies
#
#   varargs = specify as many utilities as needed.
#
#   Return: Success if all dependencies are met, failure otherwise.
#
#   Globals used (m is modified):
#       SS_RC_SUCCESS
#       SS_RC_FAILURE
#
####################################################################
#
SS_Has_Own_Dependencies()
{
    
    while [[ $# -gt 0 ]]; do
        local REPORT="$(type "$1")"
        if [[ $REPORT =~ not\ found ]]; then
            return $SS_RC_FAILURE
        fi
        shift
    done
    return $SS_RC_SUCCESS
    
}

####################################################################
# SS_Is_Category
#
#   arg1 = The item to research.
#
#   Return: Success if item is a category, failure if not.
#
#   Globals used (m is modified):
#       SS_CATEGORY_ARRAY
#       SS_RC_SUCCESS
#       SS_RC_FAILURE
#
####################################################################
#
SS_Is_Category()
{
    
    # Rename variables
    #
    local ITEM_TO_FIND="$1"
    
    local LINE
    for LINE in "${SS_CATEGORY_ARRAY[@]}"; do
        if [[ "$LINE" == "%${ITEM_TO_FIND}" ]]; then
            return $SS_RC_SUCCESS
        fi
    done
    return $SS_RC_FAILURE
    
}
 
####################################################################
# SS_Display_Category
#
#   Monolithic function which parses relevant portions of the category
#   config file, outputs formatted items, and constitutes the category
#   menu. Also waits for and in some cases routes user input.
#
#   Globals used (m is modified):
#       SS_CATEGORY_ARRAY
#       SS_NEXT_ITEM
#       SS_INDENT
#     m SS_IS_DISPLAYING_MENUS
#
####################################################################
#
SS_Display_Category()
{
    
#-Parse-the-category-array-for-the-given-category--------------------
    
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
    
#--------------------------------------------------------------------
#-Figure-out-important-formatting-values-----------------------------
    
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
    
#--------------------------------------------------------------------
#-Begin-outputting-the-menu------------------------------------------
    
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
    
#--------------------------------------------------------------------
#-Take-user-input----------------------------------------------------
    
    local SELECTION
    read -p "Select an option: " SELECTION
    echo
    
    #PURPOSEFUL STRING COMPARISON; NOT INTEGER COMPARISON
    if [[ "$SELECTION" == "0" ]]; then
        :
    elif [[ $SELECTION =~ ^[[:digit:]]+$ ]]; then
        if [[ $SELECTION -le ${#CATEGORY_ITEMS[@]} ]]; then
            SS_Push_Category "${CATEGORY_ITEM_TITLES[$SELECTION - 1]}"
        else
            echo "Not a valid selection for this menu."
        fi
    elif [[ $SELECTION =~ ^[!pq]$ ]]; then
            case "$SELECTION" in
                !)
                    SS_Recover_Wrapper
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
    
#--------------------------------------------------------------------
    
}
 
####################################################################
# SS_Display_Script
#
#   Monolithic function which dislpays the action menu for scripts.
#   Outputs the menu, takes input, acts accordingly.
#
#   Globals used (m is modified):
#       SS_NEXT_ITEM
#       SS_INDENT
#     m SS_IS_DISPLAYING_MENUS
#       SS_SCRIPT_LOCATION
#       SS_TARGET_WRAPPER
#       
####################################################################
#
SS_Display_Script()
{
    
#-Set-up-important-environment-variables-----------------------------
    
    SS_Compute_Target_Wrapper
    
    SS_Parse_Wrapper
    
#--------------------------------------------------------------------
#-Output-the-menu----------------------------------------------------
    
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
    
#--------------------------------------------------------------------
#-Take-user-input----------------------------------------------------
    
    local SELECTION
    read -p "Select an option: " SELECTION
    echo
 
    case "$SELECTION" in
        r)
            SS_IS_DISPLAYING_MENUS=false
            SS_Execute_Wrapper
            ;;
        e)
            SS_IS_DISPLAYING_MENUS=false
            SS_Edit_File "$SS_SCRIPT_LOCATION"
            ;;
        w)
            SS_IS_DISPLAYING_MENUS=false
            SS_Edit_File "$SS_TARGET_WRAPPER"
            ;;
        b)
            SS_Execute_Wrapper
            ;;
        v)
            SS_Edit_File "$SS_SCRIPT_LOCATION"
            ;;
        m)
            SS_Edit_File "$SS_TARGET_WRAPPER"
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
    
#--------------------------------------------------------------------
    
}
 
####################################################################
# SS_Execute_Wrapper
#
#   A director function which is invoked when a user wants to run
#   the script. It parses the wrapper, stores it as the last run
#   script, checks for missing dependencies, queries for options,
#   performs the final check, and coordinates the mollyguard.
#   If everything goes well, it executes the script.
#
#   Globals used (m is modified):
#       SS_USE_MOLLYGUARD
#       SS_FINAL_COMMAND
#
####################################################################
#
SS_Execute_Wrapper()
{
    
    SS_Record_Wrapper
    
    if SS_Is_Script_Missing_Dependencies ; then
        return
    fi
    
    if [[ "$SS_USE_MOLLYGUARD" == true ]]; then
        SS_Mollyguard_Pre_Options
    fi
    
    SS_Query_For_Options
    
    local FINAL_ANSWER
    echo "The following command will be executed."
    echo ${SS_FINAL_COMMAND}
    read -p "Is this okay? [y/N] " FINAL_ANSWER
    echo
    
    if ! [[ $FINAL_ANSWER =~ ^[Yy](es)?$ ]]; then
        echo "### Execution cancelled. ###"
        return
    fi
    
    if [[ "$SS_USE_MOLLYGUARD" == true ]]; then
        SS_Mollyguard_Post_Options
    fi

    $SS_FINAL_COMMAND

}

####################################################################
# SS_Record_Wrapper
#
#   Flattens the whole category history stack into a string and
#   overwrites a hard-coded file with it (.ss_last_script).
#
#   Globals used (m is modified):
#       SS_CATEGORY_HISTORY
#       SS_WORKING_DIRECTORY
#
####################################################################
#
SS_Record_Wrapper()
{
    
    local WHOLE_STACK
    local CATEGORY
    for CATEGORY in "${SS_CATEGORY_HISTORY[@]}"; do
        WHOLE_STACK="${WHOLE_STACK}/${CATEGORY}"
    done
    echo "$WHOLE_STACK" > "${SS_WORKING_DIRECTORY}.ss_last_script"
    
}
 
####################################################################
# SS_Recover_Wrapper
#
#   Overwrites the current category history stack by reading from
#   a hard-coded file. This function temporarily modifies the IFS
#   variable.
#
#   Globals used (m is modified):
#     m IFS
#       SS_WORKING_DIRECTORY
#     m SS_CATEGORY_HISTORY
#     m SS_PAGE_NUMBER
#
####################################################################
#
SS_Recover_Wrapper()
{
    
    local NEW_STACK="$(<"${SS_WORKING_DIRECTORY}"".ss_last_script")"
    
    unset SS_CATEGORY_HISTORY
    SS_PAGE_NUMBER=0
    
    local ORIGINAL_IFS="$IFS"

    IFS="/"
    
    # THIS IS THE ONLY TIME WE DON'T QUOTE THE ARRAY.
    #               \/\/\/ RIGHT THERE. NO QUOTES. QUOTES BAD.
    local ITEM     # \||/
    for ITEM in ${NEW_STACK[@]}; do
        SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]="$ITEM"
        SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER + 1 ))
    done
    
    SS_NEXT_ITEM="${SS_CATEGORY_HISTORY[@]: -1}"
    unset SS_CATEGORY_HISTORY[$SS_PAGE_NUMBER]
    SS_PAGE_NUMBER=$(( $SS_PAGE_NUMBER - 1 ))
    
    IFS="$ORIGINAL_IFS"
    
}

####################################################################
# SS_Is_Script_Missing_Dependencies
#
#   Returns: Success if missing dependencies, failure otherwise.
#
#   Checks if the dependencies specified in the wrapper file are
#   met for this script. If there are missing dependencies, this
#   will output a message stipulating which ones.
#
#   Globals used (m is modified):
#       SS_DEPENDENCIES
#       SS_RC_SUCCESS
#       SS_RC_FAILURE
#
####################################################################
#
SS_Is_Script_Missing_Dependencies()
{
    
    local -A MISSING_DEPENDENCIES
    
    local FILE_TO_CHECK
    for FILE_TO_CHECK in "${SS_DEPENDENCIES[@]}"; do
        if [[ ! -e $FILE_TO_CHECK ]]; then
            MISSING_DEPENDENCIES[$FILE_TO_CHECK]="$FILE_TO_CHECK"
        fi
    done
     
    if [[ ${#MISSING_DEPENDENCIES[@]} -gt 0 ]]; then
        local MISSING_FILE
        for MISSING_FILE in "${MISSING_DEPENDENCIES[@]}"; do
            echo "Dependency not satisfied: $MISSING_FILE is missing."
        done
        return $SS_RC_SUCCESS
    fi

    return $SS_RC_FAILURE
     
}

####################################################################
# SS_Mollyguard_Pre_Options
#
#   Presents information and interrogates the user about a dangerous
#   script.
#
#   Globals used (m is modified):
#       SS_MOLLYGUARD_MESSAGE
#       SS_SCRIPT_LOCATION
#
####################################################################
#
SS_Mollyguard_Pre_Options()
{
    
    local PREPARED_MESSAGE="${SS_MOLLYGUARD_MESSAGE:-\/\!\\\/\!\\\/\!\\ WARNING! THIS IS A DANGEROUS SCRIPT! \/\!\\\/\!\\\/\!\\}"
    
    echo
    echo -e "${PREPARED_MESSAGE#=}"
    echo
    
    echo "The following file will be executed:"
    echo $SS_SCRIPT_LOCATION
    echo
    
    if SS_Has_Own_Dependencies "date"; then
        echo "It was last modified:"
        echo $(date -r "$SS_SCRIPT_LOCATION")
    else
        echo "Unable to check last modification time. Please install 'date' for this feature."
    fi
    
    local SHOULD_VIEW
    echo
    read -p "Would you like to view the file? (Opens in editor) [Y/n] " SHOULD_VIEW
    if ! [[ $SHOULD_VIEW =~ ^[Nn][Oo]?$ ]]; then
        SS_Edit_File "$SS_SCRIPT_LOCATION"
    fi
    
}

####################################################################
# SS_Query_For_Options
#
#   The function which queries the user for option arguments in series.
#
#   Globals used (m is modified):
#       SS_OPTIONS
#     m SS_FINAL_COMMAND
#
####################################################################
#
SS_Query_For_Options()
{
    
    local COMMAND
    local INPUT_ARGUMENT
    local KEY
    for KEY in "${!SS_OPTIONS[@]}"; do
        echo -en "${SS_OPTIONS[$KEY]%%::*}"
        if [[ "${SS_OPTIONS[$KEY]}" =~ :: ]]; then
            read INPUT_ARGUMENT
            local DEFAULT_VALUE="${SS_OPTIONS[$KEY]##*::}"
            COMMAND="${COMMAND} ${KEY} ${INPUT_ARGUMENT:-${DEFAULT_VALUE}}"
        else
            read -p "[y/N] " INPUT_ARGUMENT
            if [[ "$INPUT_ARGUMENT" =~ ^[Yy](es)?$ ]]; then
                COMMAND="${COMMAND} ${KEY}"
            fi
        fi
    done
    
    local EXTRA_ARGUMENTS
    read -p "Any additional options/arguments? " EXTRA_ARGUMENTS
    COMMAND="${COMMAND} ${EXTRA_ARGUMENTS}"
    
    SS_FINAL_COMMAND="${SS_SCRIPT_LOCATION}${COMMAND}"
    
}

####################################################################
# SS_Mollyguard_Post_Options
#
#   Presents the final safety message and forces the user to either
#   confirm the execution or kill the scripting system.
#
#   Globals used (m is modified):
#       SS_FINAL_COMMAND
#       SS_SCRIPT_LOCATION
#
####################################################################
#
SS_Mollyguard_Post_Options()
{
    
    local EXECUTION_KEY
    
    echo
    echo $SS_FINAL_COMMAND
    echo
    
    echo "   /\\   Are you sure you wish to execute this script with the above options?"
    echo "  /!!\\   If so, enter the full name of the script, character for character. If not, press CTRL-C or kill $$."
    echo " /____\\   Once your input is correct, the script will execute."
    echo
    echo "Enter: ${SS_SCRIPT_LOCATION##*/}"
    while [[ "$EXECUTION_KEY" != "${SS_SCRIPT_LOCATION##*/}" ]]; do
        read EXECUTION_KEY
    done
    
}
 
####################################################################
# SS_Parse_Wrapper
#
#   Reads in the global target wrapper and parses it line by line
#   as an array. Each line can be any of four things: location,
#   dependency, option, mollyguard. It constructs global variables
#   as its output.
#
#   Globals used (m is modified):
#       SS_TARGET_WRAPPER
#     m SS_SCRIPT_LOCATION
#     m SS_DEPENDENCIES
#     m SS_OPTIONS
#     m SS_USE_MOLLYGUARD
#     m SS_MOLLYGUARD_MESSAGE
#
####################################################################
#
SS_Parse_Wrapper()
{
    
    local RAW_WRAPPER_FILE_ARRAY
    
    mapfile -t RAW_WRAPPER_FILE_ARRAY < "$SS_TARGET_WRAPPER"
    
    local DEPENDENCY_COUNT
    local OPTION_KEY

    unset SS_OPTIONS
    declare -Ag SS_OPTIONS
    
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
                SS_MOLLYGUARD_MESSAGE=${RAW_LINE##mollyguard}
            fi
        fi
    done
    
}
 
####################################################################
# SS_Read_Category_File
#
#   Read the category file into an array, excluding comments and empty
#   lines.
#
#   Globals used (m is modified):
#       SS_CATEGORY_FILE
#     m SS_CATEGORY_ARRAY
#
####################################################################
#
SS_Read_Category_File()
{
    
    local RAW_CATEGORY_FILE_ARRAY
    
    mapfile -t RAW_CATEGORY_FILE_ARRAY < "$SS_CATEGORY_FILE"
    
    local INDEX_IN_TARGET=0
    
    local RAW_LINE
    for RAW_LINE in "${RAW_CATEGORY_FILE_ARRAY[@]}"; do
        if [[ !($RAW_LINE =~ ^#.*) ]] && [[ !($RAW_LINE =~ ^$) ]]; then
            SS_CATEGORY_ARRAY[$INDEX_IN_TARGET]="$RAW_LINE"
            INDEX_IN_TARGET=$(( $INDEX_IN_TARGET + 1 ))
        fi
    done
    
}

####################################################################
# MAIN BLOCK
#
#   This is the main execution block of the script, the entry point.
#   This calls the initialization functions, and loops over the different
#   menus.
#
#   Globals used (m is modified):
#     m SS_IS_DISPLAYING_MENUS
#       SS_NEXT_ITEM
#
####################################################################

# Also remember to see if : -1} can be changed to a direct access in 4.2
 
SS_Initialize

SS_Take_Own_Options
 
SS_Read_Category_File
 
SS_IS_DISPLAYING_MENUS=true
while [[ "$SS_IS_DISPLAYING_MENUS" == true ]]; do
#    printf "\033c"
    if SS_Is_Category "$SS_NEXT_ITEM" ; then
        SS_Display_Category
    else
        SS_Display_Script
    fi
done
