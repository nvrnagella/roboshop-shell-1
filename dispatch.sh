source common.sh

if [ -z "${rabbitmq_root_password}" ];then
  echo "rabbitmq_root_password is missing"
  exit 1
fi

component=dispatch
load_schema=false
DIS