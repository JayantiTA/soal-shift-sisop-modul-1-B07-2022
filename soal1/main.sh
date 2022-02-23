# try to input username and password
printf "Input your username: "
read username
printf "Input your password: "
read -s password

function check_password() {
  local stat=1
  uname=$(awk -v var="$username" '$1 ~ var' users/user.txt)
  data="$username $password"
  if [[ $uname == $data ]]
  then
    stat=$? # return 1 for false
  fi

  echo $stat
}

if [[ $(check_password) -eq 0 ]]
then
  echo "`date +"%D %T"` LOGIN: INFO User $username logged in" >> log.txt
  printf "\nLOGIN: INFO User $username logged in"  # if register is fail
else
  echo "`date +"%D %T"` LOGIN: ERROR Failed login attempt on user $username" >> log.txt
  printf "\nLOGIN: ERROR Failed login attempt on user $username"  # if register is fail
  exit 0  # exit program if username already exists
fi

# username="JayantiTA"

echo "Input command"
read commnd n

function download_image() {
  pictureAmount=$n
  timeStampForFileName="`date "+%F"`"
  downloadFolderName="${timeStampForFileName}_${username}"
  if [ -d "${downloadFolderName}" ]
  then
    rm -rf "${downloadFolderName}"
  fi

  mkdir "${downloadFolderName}"

  if [ -e "${downloadFolderName}.zip" ]
  then
    unzip -P "${password}" "${downloadFolderName}.zip" -d "${downloadFolderName}"
    rm -rf "${downloadFolderName}.zip"
  fi

  cd "${downloadFolderName}"
  # filenameList=`ls`
  # startIndex=$((${#filenameList}))
  startIndex=`ls | wc -l`
  echo $startIndex

  for((i=1; i<=$pictureAmount; i++))
  do
    index=$(($startIndex+$i))
    if [[ $index -lt 10 ]]
    then
      wget -cO PIC_0$index https://loremflickr.com/320/240
    else
      wget -cO PIC_$index https://loremflickr.com/320/240
    fi
  done

  # zip -e ${downloadFolderName}.zip *
  zip -P $password ${downloadFolderName}.zip *
  mv ${downloadFolderName}.zip ..
  cd ..
  rm -rf "${downloadFolderName}"
}

function login_try() {
  tries=$(awk -v var="$username" '
  /log/ && $0 ~ var { ++n }
  END { print n }' log.txt)

  echo $tries
}

if [[ "$commnd" == "dl" ]]
then
  download_image
elif [[ "$commnd" == "att" ]]
then
  echo "percobaan dilakukan sebanyak: $(login_try)"
fi

exit 0
