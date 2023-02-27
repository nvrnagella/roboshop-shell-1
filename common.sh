path_location=$(pwd)
LOG=/tmp/roboshop.log
status_check (){
  if [ $? -eq 0 ]
    then
      echo SUCCESS
    else
      echo FAILURE
      echo please check the log file for know the error reason ${LOG}
      exit
  fi
}
print_head (){
echo -e "\e[1;31m $1 \e[0m"
}