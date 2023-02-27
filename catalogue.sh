source common.sh
set -e
print_head "setup nodejs repos vendor is providing the script to setup nodejs repos "
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${LOG}
status_check
print_head "installing nodejs"
yum install nodejs -y &>> ${LOG}
status_check
print_head "add the user"
useradd roboshop
status_check
print_head "create and navigate to that app directory"
mkdir -p /app
cd /app
status_check
print_head " remove old app content"
rm -rf /app/*
status_check
print_head "download the app content"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> ${LOG}
status_check
print_head "extract the app content"
unzip /tmp/catalogue.zip &>> ${LOG}
status_check
print_head "donwload the dependencies"
npm install &>> ${LOG}
status_check
print_head "copy systemd service file for starting the application"
cp ${path_location}/files/catalogue.service /etc/systemd/system/catalogue.service
status_check
print_head "reload service file"
systemctl daemon-reload
status_check
print_head "enable and start catalgoue service"
systemctl enable catalogue &>> ${LOG}
systemctl restart catalogue
status_check
print_head "load the mongo.repo file for schema to be loaded"
cp ${path_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo
status_check
print_head "install mongodb"
yum install mongodb-org-shell -y &>> ${LOG}
status_check
print_head "load the schema"
mongo --host localhost </app/schema/catalogue.js &>> ${LOG}
status_check