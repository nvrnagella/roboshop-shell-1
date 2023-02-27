path_location=$(pwd)
LOG=/tmp/roboshop.log
status_check (){
  if [ $? -eq 0 ]
    then
      echo SUCCESS
    else
      echo FAILURE
  fi
}
print_head (){
echo -e "\e[31m $1 \e[0m"
}