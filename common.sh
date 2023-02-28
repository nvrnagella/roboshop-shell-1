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
      status_check
    fi
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
    if [ ${load_schema} == "true" ]; then
      if [ ${schema_type} == "true" ]; then
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
      if [ ${schema_type} == "true" ]; then
        print_head "We need to load the schema. To load schema we need to install mysql client."
        yum install mysql -y
        status_check
        print_head "Load Schema"
        mysql -h mysql-dev.nvrnagella.online -uroot -p${root_mysql_password} </app/schema/${component}.sql
        status_check
        print_head "This service needs a restart because it is dependent on schema, After loading schema only it will work as expected, Hence we are restarting this service. This"
        systemctl restart ${component}
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
  yum install maven -y
  status_check
  APP_PREREQ
  print_head "Lets download the dependencies & build the application"
  mvn clean package &>> ${LOG}
  mv target/shipping-1.0.jar shipping.jar
  status_check
  SYSTEMD_SETUP
  LOAD_SCHEMA
}