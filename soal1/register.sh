# try to input username
printf "================================\n"
printf "!!!Welcome to register.sh!!!\n"
printf "================================\n"
printf "Input your username: "
read username

# to check is username already exists
function check_username() {
  local user_exists=0
  
  for user in $(awk -F" " '{ print }' users/user.txt)
  do
    if [ $user == $username ]
    then
      user_exists=1
      break  # exit program if username already exists
    fi
  done

  echo $user_exists
}
# call the function
if [[ $(check_username) -gt 0 ]]
then
  echo "`date +"%D %H:%M:%S"` REGISTER: ERROR User already exists" >> log.txt
  printf "\n-----------------------------------"
  printf "\nREGISTER: ERROR User already exists"  # if register is fail
  printf "\n-----------------------------------\n"
  exit 0  # exit program if username already exists
fi

# try to input password
printf "Input your password: "
read -s password

# to check is password valid or not
# loop until input password is valid
until [[ "$password" =~ [A-Z] && "$password" =~ [a-z] && "$password" =~ [0-9] && "$password" != "$username" && ${#password} -ge 8 ]]
do
  printf "\n------------------------------------------------------------"
  if  [[ ! $password =~ [0-9] ]]
  then 
    printf "\nERROR: Password must contain at least one number"
  fi
  if [[ ! $password =~ [a-z] ]]
  then
    printf "\nERROR: Password must contain at least one lowercase letter"
  fi
  if [[ ! $password =~ [A-Z] ]]
  then
    printf "\nERROR: Password must contain at least one uppercase letter"
  fi
  if [[ ${#password} -lt 8 ]]
  then
    printf "\nERROR: Password must be at least 8 characters long"
  fi
  if [[ $password == $username ]]
  then
    printf "\nERROR: Password must not be the same as the username"
  fi
  printf "\n------------------------------------------------------------"

  printf "\nPlease input password again: "
  read -s password
done

# write username and password to users/user.txt
echo "$username $password" >> ./users/user.txt

# if register is success
echo "`date +"%D %H:%M:%S"` REGISTER: INFO User $username registered successfully" >> log.txt
printf "\n-----------------------------------------------------"
printf "\nREGISTER: INFO User $username registered successfully"
printf "\n-----------------------------------------------------\n"
