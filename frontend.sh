source common.sh

echo -e "\e[31m Install Nginx \e[0m"
yum install nginx -y &>> ${LOG}
echo -e "\e[31m enable and start nginx \e[0m"
systemctl enable nginx &>> ${LOG}
systemctl start nginx
echo -e "\e[31m remove old content of the nginx \e[0m"
rm -rf /usr/share/nginx/html/*
echo -e "\e[31m download content from remote place \e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> ${LOG}
echo -e "\e[31m navigagte to that directory \e[0m"
cd /usr/share/nginx/html
echo -e "\e[31m extract that content \e[0m"
unzip /tmp/frontend.zip &>> ${LOG}
echo -e "\e[31m copy reverse proxy \e[0m"
cp $path_location/files/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf
echo -e "\e[31m restart nginx \e[0m"
systemctl restart nginx
