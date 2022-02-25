# try to input username
printf "===========================\n"
printf "!!!Welcome to login page!!!\n"
printf "===========================\n"
printf "Input your username: "
read username
printf "Input your password: "
read -s password

function check_password() {
  local is_correct=1
  data_from_file=$(awk -v var="$username" '$1 ~ var' users/user.txt)
  data_from_input="$username $password"
  if [[ $data_from_file == $data_from_input ]]
  then
    is_correct=$? # return 1 for false
  fi

  echo $is_correct
}

if [[ $(check_password) == 0 ]]
then
  echo "`date +"%D %T"` LOGIN: INFO User $username logged in" >> log.txt
  printf "\n--------------------------------------"
  printf "\nLOGIN: INFO User $username logged in"  # if log in is fail
  printf "\n--------------------------------------"
else
  echo "`date +"%D %T"` LOGIN: ERROR Failed login attempt on user $username" >> log.txt
  printf "\n---------------------------------------------------------"
  printf "\nLOGIN: ERROR Failed login attempt on user $username"  # if log in is fail
  printf "\n---------------------------------------------------------"
  exit 0  # exit program if username already exists
fi

printf "\nInput command: "
read commnd n

function download_image() {
  picture_amount=$n
  time_stamp_for_file_name="`date "+%F"`"
  download_folder_name="${time_stamp_for_file_name}_${username}"

  if [ -d "${download_folder_name}" ]
  then
    rm -rf "${download_folder_name}"
  fi

  mkdir "${download_folder_name}"

  if [ -e "${download_folder_name}.zip" ]
  then
    unzip -P "${password}" "${download_folder_name}.zip" -d "${download_folder_name}"
    rm -rf "${download_folder_name}.zip"
  fi

  cd "${download_folder_name}"
  start_index=`ls | wc -l`

  for((i=1; i<=$picture_amount; i++))
  do
    index=$(($start_index+$i))
    if [[ $index -lt 10 ]]
    then
      wget -cO PIC_0$index https://loremflickr.com/320/240
    else
      wget -cO PIC_$index https://loremflickr.com/320/240
    fi
  done

  zip -P $password ${download_folder_name}.zip *
  mv ${download_folder_name}.zip ..
  cd ..
  rm -rf "${download_folder_name}"
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
  printf "\n------------------------------"
  printf "\nSUCCESS downloaded $n pictures"
  printf "\n------------------------------\n"
elif [[ "$commnd" == "att" ]]
then
  printf "\n----------------------------"
  printf "\nLOGIN attempts: $(login_try)"
  printf "\n----------------------------\n"
else
  printf "\n----------------------------"
  printf "\nERROR: Invalid command"
  printf "\n----------------------------\n"
fi

exit 0
