#!/bin/bash

LOG_DIRECTORY="log"

monthDay=(0 31 28 31 30 31 30 31 31 30 31 30 31)

logFileName="metrics_agg_`date +%Y%m%d%H`.log"

currentTime=($((`date +%-H`)) $((`date +%-M` * 60 + `date +%-S`)))
currentDate=($((`date +%-Y`)) $((`date +%-m`)) $((`date +%-d`)))

if [ ! -d "${HOME}/${LOG_DIRECTORY}" ]
then
	mkdir "${HOME}/${LOG_DIRECTORY}"
fi

fileList=`ls "${HOME}/${LOG_DIRECTORY}"`

# Untuk menghitung waktu sejam sebelumnya.
# Kondisi bila jam 0 (12 malam lebih), bila dihitung sejam sebelumnya
# akan mundur ke hari sebelumnya, menyebabkan banyak masalah.
# Masalah diantaranya adalah Februari bisa tanggal 28 atau 29,
# kabisat terjadi pada tahun kelipatan 400 atau kelipatan 4 dan bukan kelipatan 100
# Bisa juga mundur tahun karena di tanggal 1 januari
if [ ${currentTime[0]} -eq 0 ]
then
	lowerBoundDate=(${currentDate[0]} ${currentDate[1]} ${currentDate[2]})
	lowerBoundTime=(23 ${currentTime[1]})
	
	if [ ${currentDate[2]} -eq 1 ]
	then
		if [ ${currentDate[1]} -eq 3 ]
		then
			${lowerBoundDate[1]}=2
			
			if [ $((${currentDate[0]} % 400)) -eq 0 ]
			then
				${lowerBoundDate[2]}=29
			elif [ $((${currentDate[0]} % 4)) -eq 0 ] && [ $((${currentDate[0]} % 100)) -ne 0 ]
			then
				${lowerBoundDate[2]}=29
			else
				${lowerBoundDate[2]}=28
			fi
		elif [ ${currentDate[1]} -eq 1 ]
		then
			${lowerBoundDate[2]}=31
			${lowerBoundDate[1]}=12
			${lowerBoundDate[0]}=$((${currentDate[0]}-1))
		else
			${lowerBoundDate[1]}=$((${currentDate[1]}-1))
			${lowerBoundDate[2]}=${monthDay[${lowerBoundDate[1]}]}
		fi
	else
		${lowerBoundDate[2]}=$((${lowerBoundDate[2]}-1))
	fi
else
	lowerBoundTime=($((${currentTime[0]}-1)) ${currentTime[1]})
	
	lowerBoundDate=(${currentDate[0]} ${currentDate[1]} ${currentDate[2]})
fi

#echo "${currentDate[0]}-${currentDate[1]}-${currentDate[2]} ${currentTime[0]}:${currentTime[1]}"
#echo "${lowerBoundDate[0]}-${lowerBoundDate[1]}-${lowerBoundDate[2]} ${lowerBoundTime[0]}:${lowerBoundTime[1]}"


eligibleFile=0
total=(0 0 0 0 0 0 0 0 0 0)
minimum=(0 0 0 0 0 0 0 0 0 0)
maximum=(0 0 0 0 0 0 0 0 0 0)

for file in $fileList
do
	# tanda 10# memaksa convert string ke integer basis 10
	# karena bila tidak, akan diubah dengan basis 8
	# jika ada leading zero pada string
	
	if [ ${#file} -eq 26 ] && [ ${file:0:8} == "metrics_" ] && [ ${file:0:12} != "metrics_agg_" ]
	then
		fileYear=$((10#${file:8:4}))
		fileMonth=$((10#${file:12:2}))
		fileDay=$((10#${file:14:2}))
		fileHour=$((10#${file:16:2}))
		fileSeconds=$((10#${file:18:2} * 60 + 10#${file:20:2}))
		
		#echo "$fileYear $fileMonth $fileDay $fileHour $fileMinute $fileSecond"
		
		# Jadi untuk mencari di antara jam, maka hanya perlu mencari
		# nama file dengan tahun, bulan, hari, dan jam yang sama dengan
		# jam batas bawah atau batas atas (mengapa? karena perbedaan hanya
		# setiap 1 jam, kalau setiap 2 jam tidak akan bisa)
		# misalnya jam 15:30:00, yang dicari 
		# dari jam 14:30:00 sampai 15:30:00
		# nah kalau sama dengan batas bawah, maka menit-detik-nya 
		# harus lebih, kalau batas atas, maka menit-detik-nya harus kurang
		
		if [ $fileYear -eq ${lowerBoundDate[0]} ] && [ $fileMonth -eq ${lowerBoundDate[1]} ] && [ $fileDay -eq ${lowerBoundDate[2]} ] && [ $fileHour -eq ${lowerBoundTime[0]} ]
		then
			if [ $fileSeconds -ge ${lowerBoundTime[1]} ]
			then
				eligibleFile=$(($eligibleFile+1))
				data=( `awk '
					BEGIN {
						FS = ","
					}
					{
						print $1, " ", $2, " ", $3, " ", $4, " ", $5, " ", $6, " ", $7, " ", $8, " ", $9, " ", $11
					}
				' "${HOME}/${LOG_DIRECTORY}/${file}"`)
				
				data[9]=${data[9]:0:$((${#data[9]}-1))}
				
				for((i=0; i<10; i++))
				do
					total[$i]=$((${total[$i]}+${data[$i]}))
					if [ $((${minimum[$i]})) -gt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						minimum[$i]=$((${data[$i]}))
					elif [ $((${maximum[$i]})) -lt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						maximum[$i]=$((${data[$i]}))
					fi
				done
			fi
		elif [ $fileYear -eq ${currentDate[0]} ] && [ $fileMonth -eq ${currentDate[1]} ] && [ $fileDay -eq ${currentDate[2]} ] && [ $fileHour -eq ${currentTime[0]} ]
		then
			if [ $fileSeconds -le ${currentTime[1]} ]
			then
				eligibleFile=$(($eligibleFile+1))
				data=( `awk '
					BEGIN {
						FS = ","
					}
					{
						print $1, " ", $2, " ", $3, " ", $4, " ", $5, " ", $6, " ", $7, " ", $8, " ", $9, " ", $11
					}
				' "${HOME}/${LOG_DIRECTORY}/${file}"`)
				
				data[9]=${data[9]:0:$((${#data[9]}-1))}
				
				for((i=0; i<10; i++))
				do
					total[$i]=$((${total[$i]}+${data[$i]}))
					if [ $((${minimum[$i]})) -gt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						minimum[$i]=$((${data[$i]}))
					elif [ $((${maximum[$i]})) -lt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						maximum[$i]=$((${data[$i]}))
					fi
				done
			fi
		fi
	fi
done

logText="minimum"

for((i=0; i<10; i++))
do
	for((i=0; i<9; i++))
	do
		logText="${logText},${minimum[$i]}"
	done
	logText="${logText},${HOME}/"
	logText="${logText},${minimum[9]}M\n"
done

logText="${logText}maximum"

for((i=0; i<10; i++))
do
	for((i=0; i<9; i++))
	do
		logText="${logText},${maximum[$i]}"
	done
	logText="${logText},${HOME}/"
	logText="${logText},${maximum[9]}M\n"
done

logText="${logText}average"
if [ $eligibleFile -gt 0 ]
then
	for((i=0; i<9; i++))
	do
		division=`echo "scale=1; ${total[$i]}/${eligibleFile}" | bc`
		logText="${logText},${division}"
	done
	logText="${logText},${HOME}/"
	
	division=`echo "scale=1; ${total[9]}/${eligibleFile}" | bc`
	logText="${logText},${division}M"
else
	logText="${logText},0,0,0,0,0,0,0,0,0,${HOME}/,0M"
fi

printf "$logText" > "${HOME}/${LOG_DIRECTORY}/${logFileName}"
