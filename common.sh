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
APP_PREREQ () {
    print_head "add the user"
    id roboshop &>> ${LOG}
    if [ $? != 0 ]
    then
      useradd roboshop
    fi
    status_check
    print_head "create and navigate to that app directory"
    mkdir -p /app
    cd /app
    status_check
    print_head " remove old app content"
    rm -rf /app/*
    status_check
    print_head "download the app content"
    curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${LOG}
    status_check
    print_head "extract the app content"
    unzip /tmp/${component}.zip &>> ${LOG}
    status_check
}
SYSTEMD_SETUP (){
    print_head "copy systemd service file for starting the application"
    cp ${path_location}/files/${component}.service /etc/systemd/system/${component}.service
    status_check
    print_head "reload service file"
    systemctl daemon-reload
    status_check
    print_head "enable and start ${component} service"
    systemctl enable ${component} &>> ${LOG}
    systemctl restart ${component}
    status_check
}
LOAD_SCHEMA (){
    if [ "${schema_load}" == "true" ]; then
      if [ "${schema_type}" == "mongo" ]; then
        print_head "load the mongo.repo file for schema to be loaded"
        cp ${path_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo
        status_check
        print_head "install mongodb"
        yum install mongodb-org-shell -y &>> ${LOG}
        status_check
        print_head "load the schema"
        mongo --host mongodb-dev.nvrnagella.online </app/schema/${component}.js &>> ${LOG}
        status_check
      fi
      if [ "${schema_type}" == "mysql" ]; then
        print_head "We need to load the schema. To load schema we need to install mysql client."
        yum install mysql -y &>> ${LOG}
        status_check
        print_head "Load Schema"
        mysql -h mysql-dev.nvrnagella.online -uroot -p${mysql_root_password} < /app/schema/${component}.sql &>> ${LOG}
        status_check
      fi
    fi
}
NODEJS (){
  print_head "setup nodejs repos vendor is providing the script to setup nodejs repos "
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${LOG}
  status_check
  print_head "installing nodejs"
  yum install nodejs -y &>> ${LOG}
  status_check

  APP_PREREQ

  print_head "donwload the dependencies"
  npm install &>> ${LOG}
  status_check
  SYSTEMD_SETUP
  LOAD_SCHEMA
}
MAVEN (){
  print_head "Maven is a Java Packaging software, Hence we are going to install maven, This indeed takes care of java installation."
  yum install maven -y &>> ${LOG}
  status_check
  APP_PREREQ
  print_head "Lets download the dependencies & build the application"
  mvn clean package &>> ${LOG}
  mv target/${component}-1.0.jar ${component}.jar
  status_check
  SYSTEMD_SETUP
  LOAD_SCHEMA
}
PYTHON (){
  print_head "Install Python 3.6"
  yum install python36 gcc python3-devel -y &>> ${LOG}
  status_check
  APP_PREREQ
  print_head "Lets download the dependencies."
  pip3.6 install -r requirements.txt &>> ${LOG}
  status_check
  print_head "updating rabbitmq_root_password in payment service file"
  sed -i -e "s/rabbitmq_root_password/${rabbitmq_root_password}/" ${path_location}/files/${component}.service
  status_check
  SYSTEMD_SETUP
}
DIS (){
  print_head "Install GoLang"
  yum install golang -y &>> ${LOG}
  status_check
  APP_PREREQ
  print_head "Lets download the dependencies & build the software."
  cd /app
  go mod init dispatch &>> ${LOG}
  go get
  go build
  status_check
  print_head "updating rabbitmq_root_password in dispatch service file"
  sed -i -e "s/rabbitmq_root_password/${rabbitmq_root_password}/" ${path_location}/files/${component}.service
  status_check
  SYSTEMD_SETUP
}