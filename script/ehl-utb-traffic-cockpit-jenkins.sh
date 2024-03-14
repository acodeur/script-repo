#!/bin/bash

## This script is used to build traffic-cockpit backend service

remote_package_dir="/var/lib/jenkins/workspace/ehl-utb-traffic-cockpit-microservice"
package_name="traffic-cockpit.jar"
app_dir="/root/apps/traffic-cockpit/backend"
config_dir="$app_dir/config"

if [ ! -d "$app_dir" ];then
  mkdir -p "$app_dir"
fi

if [ ! -d "$config_dir" ];then
  mkdir -p "$config_dir"
fi

# transfer package
scp -i /root/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:"${remote_package_dir}"/target/"${package_name}" "${app_dir}"
scp -i /root/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:"${remote_package_dir}"/bin/traffic-cockpit.sh "${app_dir}"
scp -i /root/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:"${remote_package_dir}"/target/classes/*.yml "${config_dir}"
scp -i /root/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:"${remote_package_dir}"/Dockerfile "${app_dir}"
scp -i /root/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:"${remote_package_dir}"/docker-compose.yml "${app_dir}"

# restart
sh "$app_dir"/traffic-cockpit.sh stop
sh "$app_dir"/traffic-cockpit.sh start dev
