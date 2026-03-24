#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-17-jdk -y
sudo apt install tomcat10 tomcat10-admin tomcat10-docs tomcat10-common git -y
sudo snap install aws-cli --classic
sudo su
aws s3 cp s3://artifact-bucket-aosidjfaosdijfqewklksd/vprofile-v2.war /tmp/
systemctl daemon-reload
systemctl stop tomcat10
rm -rf /var/lib/tomcat10/webapps/ROOT
cp /tmp/vprofile-v2.war /var/lib/tomcat10/webapps/ROOT.war
systemctl start tomcat10