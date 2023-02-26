path_location=$(pwd)
#Install Nginx
yum install nginx -y
# enable and start nginx
systemctl enable nginx
systemctl start nginx
#remove old content of the nginx
rm -rf /usr/share/nginx/html/*
#download content from remote place
curl -o /tmp/frontend.sh https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
#navigagte to that directory
cd /usr/share/nginx/html
#extract that content
unzip /tmp/frontend.zip
#copy reverse proxy
cp $path_location/files/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf
#restart nginx
systemctl restart nginx
