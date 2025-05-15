#!/bin/bash
yum update -y
yum install java-1.8.0 -y
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar -xzf apache-tomcat-9.0.75.tar.gz -C /opt/
mv /opt/apache-tomcat-9.0.75 /opt/tomcat
chmod +x /opt/tomcat/bin/*.sh
