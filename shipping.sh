source common.sh

print_head "Maven is a Java Packaging software, Hence we are going to install maven, This indeed takes care of java installation."
yum install maven -y &>> ${LOG}
status_check
