source common.sh
#setiing up yum repos for mongodb
cp ${path_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo
#installing mongodb
yum install mongodb-org -y
# enable and start mongodb
systemctl enable mongod
systemctl start mongod
#update listen address
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
systemctl restart mongod