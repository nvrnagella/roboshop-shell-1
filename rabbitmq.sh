source common.sh
if [ -z "${rabbitmq_root_password}" ];then
  echo "rabbitmq root password is missing"
  exit 1
fi
print_head "Configure YUM Repos from the script provided by vendor."
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>> ${LOG}
status_check
print_head "Install ErLang"
yum install erlang -y &>> ${LOG}
status_check
print_head "Configure YUM Repos for RabbitMQ."
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> ${LOG}
status_check
print_head "Install RabbitMQ"
yum install rabbitmq-server -y &>> ${LOG}
status_check
print_head "Start RabbitMQ Service"
systemctl enable rabbitmq-server &>> ${LOG}
systemctl start rabbitmq-server
status_check
print_head "RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect. Hence, we need to create one user for the application."
rabbitmqctl add_user roboshop ${rabbitmq_root_password} &>> ${LOG}
rabbitmqctl set_user_tags roboshop administrator &>> ${LOG}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> ${LOG}
status_check