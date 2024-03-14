#!/bin/bash

# This script is used to build backend of ehl-utb-themeportrait-microservice

remote_package_dir='/var/lib/jenkins/workspace/ehl-utb-themeportrait-microservice/ehl-utb-themeportrait-microservice/target'
app_backup_dir='/home/ehl-utb-themeportrait-web.bak/tmp'
tomcat_root_dir='/usr/local/software/apache-tomcat-9.0.27'

# prepare backend package
scp -i ~/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:${remote_package_dir}/ehl-utb-themeportrait-web.war ~/apps/
echo 'prepare backend package done!'

# backup app
if [ ! -d ${app_backup_dir} ]; then mkdir -p ${app_backup_dir}; fi
rm -rf ${app_backup_dir}/*
cp -r ${tomcat_root_dir}/webapps/ehl-utb-themeportrait-web/ ${app_backup_dir}
echo 'backup app done!'

# remove previous war and deployed files
rm -rf ${tomcat_root_dir}/webapps/ehl-utb-themeportrait-web.war
rm -rf ${tomcat_root_dir}/webapps/ehl-utb-themeportrait-web
echo 'remove previous war and deployed files done!'

# deploy backend package
cp ~/apps/ehl-utb-themeportrait-web.war ${tomcat_root_dir}/webapps/
echo 'deploy backend package done!'

# restart service
sh ${tomcat_root_dir}/bin/restart.sh
echo 'restart service done!'

# recover front-end
sleep 5
\cp -rf ${app_backup_dir}/ehl-utb-themeportrait-web/WEB-INF/classes/static/ ${tomcat_root_dir}/webapps/ehl-utb-themeportrait-web/WEB-INF/classes/
echo 'recover front-end done!'

echo 'build completed!'
