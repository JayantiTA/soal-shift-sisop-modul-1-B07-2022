#!/bin/bash

LOG_DIRECTORY="log"

logFileName="metrics_`date +%Y%m%d%H%M%S`.log"

if [ ! -d "${HOME}/${LOG_DIRECTORY}" ]
then
	mkdir "${HOME}/${LOG_DIRECTORY}"
fi

memoryData=( `free -m` )

logText="${memoryData[7]}"

for((i=8; i<=12; i++))
do
	logText="${logText},${memoryData[$i]}"
done

for((i=14; i<=16; i++))
do
	logText="${logText},${memoryData[$i]}"
done

userDirectorySize=( `du -sh ${HOME}` )
logText="${logText},${HOME}/,${userDirectorySize[0]}\n"

printf "${logText}" > "${HOME}/${LOG_DIRECTORY}/${logFileName}"
