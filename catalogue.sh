source common.sh
set -e
#setup nodejs repos vendor is providing the script to setup nodejs repos
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
#installing nodejs
yum install nodejs -y
#add the user
#useradd roboshop
#create and navigate to that app directory
mkdir -p /app
cd /app
# remove old app content
rm -rf /app/*
#download the app content
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
#extract the app content
unzip /tmp/catalogue.zip
#donwload the dependencies
npm install
#copy systemd service file for starting the application
cp ${path_location}/files/catalogue.service /etc/systemd/system/catalogue.service
#reload service file
systemctl daemon-reload
#enable and start catalgoue service
systemctl enable catalogue
systemctl restart catalogue
#load the mongo.repo file for schema to be loaded
cp ${path_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo
#install mongodb
yum install mongodb-org-shell -y
#load the schema
mongo --host 172.31.13.227 </app/schema/catalogue.js