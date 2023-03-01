source common.sh

if [ -z "${rabbitmq_root_password}" ];then
  echo "rabbitmq_root_password is missing"
  exit 1
fi

component=payment
load_schema=false
PYTHON