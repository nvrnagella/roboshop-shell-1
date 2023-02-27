source common.sh
print_head "setiing up yum repos for mongodb"
cp ${path_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo
print_head "installing mongodb"
yum install mongodb-org -y &>> ${LOG}
print_head "enable and start mongodb"
systemctl enable mongod &>> ${LOG}
systemctl start mongod
print_head "update listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
print_head "restarting mongod"
systemctl restart mongod