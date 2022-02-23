# try to input username
printf "Input your username: "
read username

# to check is username already exists
function check_username() {
  local stat=1
  uname=$(awk -v var="$username" '$1 ~ var' users/user.txt)

  if [[ ${#uname} -gt 0 ]]
  then
    stat=$? # return 1 for false
  fi

  echo $stat
}
# call the function
if [[ $(check_username) -eq 0 ]]
then
  echo "`date +"%D %H:%M:%S"` REGISTER: ERROR User already exists" >> log.txt
  echo "REGISTER: ERROR User already exists"  # if register is fail
  exit 0  # exit program if username already exists
fi

# try to input password
printf "Input your password: "
read -s password

# to check is password valid or not
function validate_password() {
  local stat=1  #assigns 1 to (stat)
  length=${#password} #counts each character in the password length

  # checks for nums, lowercase, uppercase, leght of password, not equal to username
  if  [[ $password =~ [0-9] ]] && [[ $password =~ [a-z] ]] && [[ $password =~ [A-Z] ]]  && [[ "$length" -ge 8 ]] && [[ $password != $username ]]
  then 
    stat=$? #return 1 for false
  fi

  echo $stat
}
# loop until input password is valid
until [[ $(validate_password) -eq 0 ]]
do
  echo "Your input password is invalid"
  echo "Input password again: "
  read -s password
done

# write username and password to users/user.txt
echo "$username $password" >> ./users/user.txt

# if register is success
echo "`date +"%D %H:%M:%S"` REGISTER: INFO User $username registered successfully" >> log.txt
echo "REGISTER: INFO User $username registered successfully"
