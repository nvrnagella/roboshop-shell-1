source common.sh

print_head "Install Nginx"
yum install nginx -y &>> ${LOG}
status_check
print_head " enable and start nginx "
systemctl enable nginx &>> ${LOG}
status_check
systemctl start nginx
status_check
print_head " remove old content of the nginx "
rm -rf /usr/share/nginx/html/*
status_check
print_head " download content from remote place "
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> ${LOG}
status_check
print_head " navigagte to that directory "
cd /usr/share/nginx/html
status_check
print_head " extract that content "
unzip /tmp/frontend.zip &>> ${LOG}
status_check
print_head " copy reverse proxy "
cp $path_location/files/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf
status_check
print_head " restart nginx "
systemctl restart nginx
status_check