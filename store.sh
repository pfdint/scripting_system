#!/bin/bash
 
#[[ -n $(grep "^%$itemname$" categories.config) ]]
 
mapfile -t myarry < categories.config
itemname=$1
 
#iscategory=false
 
# check if is a category using builtins
#for line in ${myarry[@]}; do
#    if [[ $line == "%$itemname" ]]; then
#        iscategory=true
#        break
#    fi
#done
 
#if [[ "$iscategory" == true ]]; then
#    echo "IS A CATEGORY"
#else
#    echo "is not a category"
#fi
 
startline=0
endline=${#myarry[@]}
found=false
for (( index=0; index < ${#myarry[@]}; index++)) ; do
#    echo "comparing ${myarry[$index]} to %$itemname"
    if [[ ${myarry[$index]} =~ ^%$itemname$ ]]; then
#        echo "    ^^^found"
        startline=$index
        found=true
    elif [[ "$found" == true ]] && [[ ${myarry[$index]} =~ ^%.+ ]]; then
#        echo "    ^^^END"
        endline=$index
        break
    fi
done
 
#echo original startline $startline
#echo original endline $endline
 
startline=$(( $startline + 1 ))
distance=$(( $endline - $startline ))
 
#echo new startline is $startline
#echo "distance is $distance"
 
result=( "${myarry[@]:$startline:$distance}" )
 
#echo "\\/ \\/ \\/"
#echo ${result[@]}
#echo "/\\ /\\ /\\"
 
items=( "${result[@]%%::*}" )
descriptions=( "${result[@]##*::}" )
 
#echo
#echo "\\/ This is the items array"
#echo ${items[@]}
#echo
#echo "\\/ This is the descriptions array"
#echo ${descriptions[@]}
 
#echo
#for i in "${result[@]}"; do
#    echo in result: $i
#done
#echo
 
# Display function
#maybe someday we'll use tput. That might be a dependency, though.
 
#first, figure out our maxes
 
#max for numbers
lastNumber=${#result[@]}
numberMaxLength=${#lastNumber}
#echo $numberMaxLength is max number length
 
#max for names of items
for word in "${items[@]}"; do
    nameLength[${#word}]="$word"
done
maxword=${nameLength[@]: -1}
#echo $maxword is the longest word
#echo and ${#maxword} is the length of that word
 
echo
echo
echo =====================================
echo $itemname
echo =====================================
echo
 
#for itemNumber in ${!result[@]}; do
#    echo "    $(( $itemNumber + 1 ))  - ${items[$itemNumber]} .............. ${descriptions[$itemNumber]}"
#done
 
permapad=".........."
 
for itemNumber in ${!items[@]}; do
    identNumber=$(( $itemNumber + 1 ))
    itemName=${items[$itemNumber]}
    unset identifier
    for (( iteration=0; iteration < $numberMaxLength - ${#identNumber}; iteration++ )); do
        identifier="$itentifier "
    done
    identifier="$identNumber$identifier - "
    dots=$(( ${#maxword} - ${#itemName} ))
    unset pad
    for (( iteration=0; iteration < $dots; iteration++ )); do
        pad="${pad}."
    done
    echo "    $identifier${items[$itemNumber]} $pad$permapad ${descriptions[$itemNumber]}"
done
 
echo "    ----"
echo "    p  - return to previous menu"
echo "    q  - quit"
echo
 
echo valid selections are 1..${#result[@]}
read -p "Select an option: " selection
 
# PURPOSEFUL STRING COMPARISON; NOT INTEGER COMPARISON
if [[ "$selection" == "0" ]]; then
    nextcategory=$itemname
    echo will redisplay ourselves
elif [[ $selection =~ ^[[:digit:]]+$ ]]; then
    echo we are going to check if that is a valid selection
    if [[ $selection -le ${#result[@]} ]]; then
        echo good job
        echo ${items[$selection - 1]} will be the next menu
    else
        echo not a valid selection for this menu
    fi
elif [[ "$selection" =~ ^[pq]$ ]]; then
    case "$selection" in
        p)
            echo p was selected
            ;;
        q)
            echo q was selected
            ;;
    esac
else
    echo that was not valid input and you know it
fi
