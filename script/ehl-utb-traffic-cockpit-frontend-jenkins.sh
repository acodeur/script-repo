#!/bin/bash

# This script is used to build frontend of ehl-utb-traffic-cockpit

if [ "$#" -ge 1 ]; then
  jenkinsWorkspace=$1
else
  echo "at least one params required!" 1>&2
  exit 1
fi

# initialize variables
remote_package_dir="${jenkinsWorkspace}/dist"
app_package_dir="/root/apps/traffic-cockpit/frontend/dist"
#frontend_root_dir="/home/data/docker/volumes/erhuan_traffic_cockpit_nginx_www/_data/traffic-cockpit"
frontend_root_dir="/root/apps/traffic-cockpit/frontend/web"

# mkdir if not exist
if [ ! -d ${app_package_dir} ]; then mkdir -p ${app_package_dir}; fi

# prepare frontend package
rm -rf "${app_package_dir:?}"/*
scp -i ~/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:"${remote_package_dir}/web.zip*" "${app_package_dir}"
echo '>>> transfer frontend package to '${app_package_dir}/' done!'

# check package
if [ "$(ls ${app_package_dir})" == "" ]; then
  echo '>>> No package available!'
  exit 3
fi

# remove previous deployed files
rm -rf ${frontend_root_dir:?}/*
echo ">>> remove previous deployed files in '${frontend_root_dir}/' done!"

# deploy frontend package
\cp -f "${app_package_dir}"/web.zip ${frontend_root_dir}
cd ${frontend_root_dir}
unzip web.zip
echo ">>> deploy frontend package to '${frontend_root_dir}/' done!"

echo ">>> build completed!"

