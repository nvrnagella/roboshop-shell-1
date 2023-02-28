source common.sh

if [ -z ${mysql_root_password} ]
then
  echo mysql_root_password is missing
fi

print_head "CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version."
dnf module disable mysql -y &>> ${LOG}
status_check
print_head "Setup the MySQL5.7 repo file"
cp ${path_location}/files/mysql.repo /etc/yum.repos.d/mysql.repo
status_check
print_head "Install MySQL Server"
yum install mysql-community-server -y &>> ${LOG}
status_check
print_head "Start MySQL Service"
systemctl enable mysqld &>> ${LOG}
systemctl start mysqld
status_check
print_head "We need to change the default root password in order to start using the database service"
mysql_secure_installation --set-root-pass ${mysql_root_password}
status_check