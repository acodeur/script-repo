#!/bin/bash

# This script is used to build frontend of ehl-utb-supervise-service

if [ "$#" -ge 2 ]; then
  jenkinsWorkspace=$1
  tomcatName=$2
else
  echo "at least two params required!" 1>&2
  exit 1
fi

# initialize variables
remote_package_dir="${jenkinsWorkspace}/supervise-vue"
app_package_dir="/root/apps/supervise/dist"
tomcat_frontend_root_dir="/usr/local/software/${tomcatName}/webapps/supervise-service/WEB-INF/classes/static"

# mkdir if not exist
if [ ! -d ${app_package_dir} ]; then mkdir -p ${app_package_dir}; fi

# prepare frontend package
rm -rf "${app_package_dir:?}"/*
scp -i ~/.ssh/id_rsa_172.38.90.57 -r root@172.38.90.57:"${remote_package_dir}/dist/*" "${app_package_dir}"
echo '>>> transfer frontend package to '${app_package_dir}/' done!'

# check package
if [ "$(ls ${app_package_dir})" == "" ]; then
  echo '>>> No package available!'
  exit 3
fi

# remove previous deployed files
rm -rf ${tomcat_frontend_root_dir:?}/*
echo ">>> remove previous deployed files in '${tomcat_frontend_root_dir}/' done!"

# deploy frontend package
\cp -rf "${app_package_dir}"/* ${tomcat_frontend_root_dir}
echo ">>> deploy frontend package to '${tomcat_frontend_root_dir}/' done!"

echo ">>> build completed!"

