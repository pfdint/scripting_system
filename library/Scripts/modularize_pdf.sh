#!/bin/bash
# pdfmodularize.sh
# by pfdint
# created:23-04-2013
# modified:24-04-2013
# Used to put a pdf into chapters

printhelp() {
	echo "Specify file (-f) and groupsize (-g), optionally (-o) outputfile."
	exit 3
}

# Obtain arguments
while getopts f:g:o: argument; do
	case $argument in
	f	) originalFile="$OPTARG";;
	g	) groupsize=$OPTARG;;
	o	) outputFile="$OPTARG";;
	*	) printhelp;;
	esac
done

# Find out how many pages are in the file. This will also count as our file
# existence check.
pageTotal=`pdfinfo "$originalFile" | grep Pages | gawk '{print $2}'`
if [ -z $pageTotal ]; then
	echo "File does not exist."
	exit 2
fi

# Make sure groupsize is a number
if ! [[ "$groupsize" =~ ^[0-9]+$ ]] ; then
   exec >&2; echo "Error: Not a number or no groupsize specified."; exit 1
fi

# Check/set outputFile name
if [ -z "$outputFile" ]; then
	outputFile="$originalFile"
fi

baseName=`basename "$originalFile"`

# Split the file already!
# We do this in a temp dir, as it's rather messy.
mkdir tempPDF
cd tempPDF
pdfseparate ../"$originalFile" %d-"$baseName"

# Now start counting at 1, as pdfseparate does, and create a string which
# will act as our command arguments. 
currentPage=1
currentGroup=1
while [ $currentPage -le $pageTotal ]; do
	commandString="${commandString} ${currentPage}-${baseName}"
	if [ $(( $currentPage % $groupsize )) -eq 0 ] || [ $currentPage -eq $pageTotal ]; then
		commandString="${commandString} G${currentGroup}-${outputFile}"
		pdfunite $commandString
		currentGroup=$(($currentGroup+1))
		commandString=""
	fi
currentPage=$(($currentPage+1))
done

# Clean up
for resultFile in G*.pdf; do
	cp "$resultFile" ..
done
cd ..
rm -r tempPDF
