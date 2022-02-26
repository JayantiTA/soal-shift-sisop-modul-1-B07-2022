#!/bin/bash

DIRECTORY_FILE_RESULT="forensic_log_website_daffainfo_log"
RERATA_FILE="ratarata.txt"
RESULT_FILE="result.txt"

if [ ! -d "${DIRECTORY_FILE_RESULT}" ]
then
	mkdir "${DIRECTORY_FILE_RESULT}"
fi

awk '
	BEGIN {
		FS = ":"
		totalRequest = 0
	}
	{
		if ($1 != "\"IP\"")
		{
			totalRequest++
		}
	}
	END {
		print "Rata-rata serangan adalah sebanyak", totalRequest/12, "requests per jam"
	}
' log_website_daffainfo.log > "${DIRECTORY_FILE_RESULT}/${RERATA_FILE}"

awk '
	BEGIN {
		FS = ":"
		mostRequestIP = "NULL"
		amountOfRequestFromMostRequestIP = 0
		
		curlRequest = 0
	}
	{
		if ($1 != "\"IP\"")
		{
			dict[$1] += 1
			if (amountOfRequestFromMostRequestIP < dict[$1])
			{
				mostRequestIP = $1
				amountOfRequestFromMostRequestIP = dict[$1]
			}
			
			if (substr($9, 2, 4) == "curl")
			{
				curlRequest += 1
			}
			
			if ($3 == "02")
			{
				ipAddressAccessIn2AM[$1] = 1
			}
		}
	}
	END {
		print "IP yang paling banyak mengakses server adalah: ", mostRequestIP, " sebanyak ", dict[mostRequestIP], " requests\n"
		print "Ada ", curlRequest, " requests yang menggunakan curl sebagai user agent\n"
		
		for (i in ipAddressAccessIn2AM)
		{
			print i
		}
	}
' log_website_daffainfo.log > "${DIRECTORY_FILE_RESULT}/${RESULT_FILE}"
