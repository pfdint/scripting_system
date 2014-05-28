#!/bin/bash
# scripting_system.sh
# by pfdint
# created: 2014-05-18
# modified: 
# purpose: the master ss executable. currently displays menus and stuff.

#we need a config file to know what categories exist.
#it has to be linear
#since categories can be nested

set -o errexit

SS_Extract_Current_Category()
{
  
  # Rename arguments
  #
  local INDEX_BEGIN=$1
  local INDEX_END=$2
  local TARGET_INDEX=0
  
  for ((index=$INDEX_BEGIN; index < $INDEX_END; index++)); do
    SS_CURRENT_CATEGORY_ITEM_ARRAY[$TARGET_INDEX]=${SS_CATEGORIES_FILE_ARRAY[$index]%%::*}
    SS_CURRENT_CATEGORY_DESCRIPTION_ARRAY[$TARGET_INDEX]=${SS_CATEGORIES_FILE_ARRAY[$index]##*::}
    TARGET_INDEX+=1
  done
  
}

SS_Find_Current_Category()
{
  
#we know the category we want, and we have a global array we can't mutate
#so we have to search the array for the heading we want. can't grep it, have to check
#every item in the array.
#When we find it, we start copying it into the result array, until
#we find the next category heading. 
  
  # Rename arguments
  #
  local CATEGORY_TO_FIND=$1
  local INDEX_BEGIN=0
  local INDEX_END=0
  
  for ((index=1; index < ${#SS_CATEGORIES_FILE_ARRAY[@]}; index++)); do
    if [[ ${SS_CATEGORIES_FILE_ARRAY:1} == $CATEGORY_TO_FIND ]]; then
      INDEX_BEGIN=$index
    elif [[ ${SS_CATEGORIES_FILE_ARRAY:0:1} == "%" ]]; then
      INDEX_END=$index
    fi
  done
  
  # Now that we know our range, we will have another function extract it.
  #
  SS_Extract_Current_Category $INDEX_BEGIN $INDEX_END
  
}

#prep all of the necessary files by reading them into variables and sterilizing them
##categories file
SS_CATEGORIES_FILE_RAW="./ss_category_config"
SS_CATEGORIES_STERILIZED_FILE="./.ss_categories_sterilized"

cat $SS_CATEGORIES_FILE_RAW | sed 's/^#.*//g' | sed '/^$/d' | tee $SS_CATEGORIES_STERILIZED_FILE

mapfile SS_CATEGORIES_FILE_ARRAY < $SS_CATEGORIES_STERILIZED_FILE

for ((index=1; index < ${#SS_CATEGORIES_FILE_ARRAY[@]}; index++)); do
  SS_MASTER_ITEMS_ARRAY[$index]=${SS_CATEGORIES_FILE_ARRAY[$index]%%::*}
  SS_MASTER_DESCRIPTIONS_ARRAY[$index]=${SS_CATEGORIES_FILE_ARRAY[$index]##*::}
done

#invoke all the necessary functions to display a menu and take input

SS_Find_Current_Category "TOP LEVEL CATEGORY ONE"

#while dislpaying menu
##parse category currentcategory
##display the information we found
##wait for input from the user
##parse it and change variables accordingly
