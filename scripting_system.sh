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

SS_debug()
{
  echo "==="
  echo "$1"
  echo "==="
}

SS_Extract_Current_Category()
{
  
  # Rename arguments
  #
  local INDEX_BEGIN=$1
  local INDEX_END=$2
  local TARGET_INDEX=0
  
  for ((index3=$INDEX_BEGIN; index3 < $INDEX_END; index3++)); do
    SS_CURRENT_CATEGORY_ITEM_ARRAY[$TARGET_INDEX]=${SS_CATEGORIES_FILE_ARRAY[$index3]%%::*}
    SS_CURRENT_CATEGORY_DESCRIPTION_ARRAY[$TARGET_INDEX]=${SS_CATEGORIES_FILE_ARRAY[$index3]##*::}
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
  local BEGIN_FOUND=false
  
  for ((index2=1; index2 < ${#SS_CATEGORIES_FILE_ARRAY[@]}; index2++)); do
    if [[ ${SS_CATEGORIES_FILE_ARRAY[$index2]:1} == $CATEGORY_TO_FIND ]]; then
      INDEX_BEGIN=$index2
      BEGIN_FOUND=true
SS_debug "start category"
    elif [[ ${SS_CATEGORIES_FILE_ARRAY[$index2]:0:1} == "%" && $BEGIN_FOUND ]]; then
      INDEX_END=$index2
SS_debug "category ended"
      break
    fi
SS_debug "${SS_CATEGORIES_FILE_ARRAY[$index2]:1}"
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

for ((index1=1; index1 < ${#SS_CATEGORIES_FILE_ARRAY[@]}; index1++)); do
  SS_MASTER_ITEMS_ARRAY[$index1]=${SS_CATEGORIES_FILE_ARRAY[$index1]%%::*}
  SS_MASTER_DESCRIPTIONS_ARRAY[$index1]=${SS_CATEGORIES_FILE_ARRAY[$index1]##*::}
done

#invoke all the necessary functions to display a menu and take input

SS_Find_Current_Category "TOP LEVEL CATEGORY TWO"

echo "---"
echo ${SS_CURRENT_CATEGORY_ITEM_ARRAY[@]}

#while dislpaying menu
##parse category currentcategory
##display the information we found
##wait for input from the user
##parse it and change variables accordingly
