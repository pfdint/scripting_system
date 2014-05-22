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
  
  local 
  while [[  ]]; do
  
  done
 
  unset<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
##we know the category we want, and we have a global array we can't mutate
#so we have to search the array for the heading we want. can't grep it, have to check
#every item in the array.
#When we find it, we start copying it into the result array, until
#we find the next category heading. 
  
}

##prep all of the necessary file by reading them into variables and sterilizing them
###categories file
SS_CATEGORIES_FILE_RAW="./ss_category_config"
SS_CATEGORIES_STERILIZED_FILE="./.ss_categories_sterilized"

cat $SS_CATEGORIES_FILE_RAW | sed 's/^#.*//g' | sed '/^$/d' | tee $SS_CATEGORIES_STERILIZED_FILE

mapfile SS_CATEGORIES_FILE_ARRAY < $SS_CATEGORIES_STERILIZED_FILE

#invoke all the necessary functions to display a menu and take input

SS_Extract_Category "TOP LEVEL CATEGORY ONE"

#while dislpaying menu
##parse category currentcategory
##display the information we found
##wait for input from the user
##parse it and change variables accordingly
