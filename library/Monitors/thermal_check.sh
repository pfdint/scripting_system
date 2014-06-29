#!/bin/bash
# therm.sh
# by pfdint
# created:25-04-2013
# modified:25-04-2013
# Used to print temperatures

#All in two columns, C and F

#Print battery
#Print cores
#Print GPU

celcius_bat_1=`sensors | grep temp1 | gawk '{ print $2 }'`
celcius_bat_2=`sensors | grep temp2 | gawk '{ print $2 }'`
celcius_bat_3=`sensors | grep temp3 | gawk '{ print $2 }'`

faren_bat_1=`sensors -f | grep temp1 | gawk '{ print $2 }'`
faren_bat_2=`sensors -f | grep temp2 | gawk '{ print $2 }'`
faren_bat_3=`sensors -f | grep temp3 | gawk '{ print $2 }'`

celcius_core_0=`sensors | grep "Core 0" | gawk '{ print $3 }'`
celcius_core_1=`sensors | grep "Core 1" | gawk '{ print $3 }'`
celcius_core_2=`sensors | grep "Core 2" | gawk '{ print $3 }'`
celcius_core_3=`sensors | grep "Core 3" | gawk '{ print $3 }'`

faren_core_0=`sensors -f | grep "Core 0" | gawk '{ print $3 }'`
faren_core_1=`sensors -f | grep "Core 1" | gawk '{ print $3 }'`
faren_core_2=`sensors -f | grep "Core 2" | gawk '{ print $3 }'`
faren_core_3=`sensors -f | grep "Core 3" | gawk '{ print $3 }'`

celcius_gpu=`optirun nvidia-smi -q -d temperature | grep Gpu | gawk '{ print $3 }'`
faren_gpu=$(( ( $celcius_gpu * (9 / 5)  ) + 32 ))

printf "System Temperatures at `date +%H%M`\n"
printf "\tC\t\tF\n"
printf "\tBattery:\n"
printf "\t${celcius_bat_1}\t\t${faren_bat_1}\n"
printf "\t${celcius_bat_2}\t\t${faren_bat_2}\n"
printf "\t${celcius_bat_3}\t\t${faren_bat_3}\n"
printf "\tCPU:\n"
printf "\t${celcius_core_0}\t\t${faren_core_0}\n"
printf "\t${celcius_core_1}\t\t${faren_core_1}\n"
printf "\t${celcius_core_2}\t\t${faren_core_2}\n"
printf "\t${celcius_core_3}\t\t${faren_core_3}\n"
printf "\tGPU:\n"
printf "\t${celcius_gpu}\t\t${faren_gpu}\n"
