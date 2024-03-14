#!/bin/bash

# This script is used to build backend of ehl-utb-supervise-microservice

if [ "$#" -ge 3 ]; then
  jenkinsWorkspace=$1
  tomcatName=$2
  port=$3
else
  echo "at least three params required!" 1>&2
  exit 1
fi

# initialize variables
remote_package_dir="${jenkinsWorkspace}/supervise-service/target"
app_backup_dir='/home/ehl-utb-supervise-microservice.bak'
app_package_dir="/root/apps/supervise"
tomcat_root_dir="/usr/local/software/${tomcatName}"

# prepare backend package
scp -i ~/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:${remote_package_dir}/supervise-service.war "${app_package_dir}/"
echo '>>> prepare backend package done!'

# backup app
if [ ! -d ${app_backup_dir} ]; then mkdir -p ${app_backup_dir}; fi
rm -rf ${app_backup_dir:?}/*
cp -r "${tomcat_root_dir}"/webapps/supervise-service/ ${app_backup_dir}
echo '>>> backup app done!'

# remove previous war and deployed files
rm -rf "${tomcat_root_dir}"/webapps/supervise-service.war
rm -rf "${tomcat_root_dir}"/webapps/supervise-service
echo '>>> remove previous war and deployed files done!'

# deploy backend package
cp "${app_package_dir}"/supervise-service.war "${tomcat_root_dir}"/webapps/
echo '>>> deploy backend package done!'

# restart service
sh /root/script/tomcat-restart.sh "${tomcatName}" "${port}"
echo '>>> restart service done!'

# recover front-end
\cp -rf "${app_backup_dir}"/supervise-service/WEB-INF/classes/static/ ${tomcat_root_dir}/webapps/supervise-service/WEB-INF/classes/
echo ">>> recover front-end in '${tomcat_root_dir}/webapps/supervise-service/WEB-INF/classes/' done!"

echo ">>> build completed!"

