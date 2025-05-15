#!/bin/bash
pkill -f tomcat || true
sleep 2
/opt/tomcat/bin/startup.sh
