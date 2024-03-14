#!/bin/bash

# This script is used to build backend of ehl-utb-trafficsituation-microservice

if [ "$#" -ge 3 ]; then
  jenkinsWorkspace="$1"
  branch="$2"
  port="$3"
  if [[ ! $port =~ ^[0-9]+$ ]]; then
    echo ">>> port must be number!" 1>&2
    exit 3
  fi
  case $branch in
  *-analysis)
    echo ">>> match <$branch>"
    tomcatName="tomcat-${branch}"
    ;;
  #develop | master | milestone-demo)
  #  echo ">>> match <$branch>"
  #  tomcatName='apache-tomcat-9.0.27'
  #  ;;
  *)
    echo ">>> Unsupported branch: <$branch>"
    exit 2
    ;;
  esac

  # initialize variables
  remote_package_dir="${jenkinsWorkspace}/ehl-utb-trafficsituation-web/target"
  app_package_dir="/root/apps/ehl-utb-trafficsituation-microservice/${branch}"
  app_backup_dir="/home/ehl-utb-trafficsituation-microservice.bak/${branch}"
  tomcat_root_dir="/usr/local/software/${tomcatName}"

  # mkdir if not exist
  if [ ! -d ${app_package_dir} ]; then mkdir -p ${app_package_dir}; fi
  if [ ! -d ${app_backup_dir} ]; then mkdir -p ${app_backup_dir}; fi

  # prepare backend package
  scp -i ~/.ssh/id_rsa_172.38.90.57 root@172.38.90.57:"${remote_package_dir}"/trafficsituation.war "${app_package_dir}/"
  echo ">>> transfer backend package to '${app_package_dir}/' done!"

  # backup app
  rm -rf "${app_backup_dir:?}"/*
  cp -r ${tomcat_root_dir}/webapps/trafficsituation "${app_backup_dir}/"
  echo ">>> backup app to '${app_backup_dir}/' done!"

  # remove previous war and deployed files
  rm -rf ${tomcat_root_dir}/webapps/trafficsituation.war
  rm -rf ${tomcat_root_dir}/webapps/trafficsituation
  echo ">>> remove previous war and deployed files in '${tomcat_root_dir}/webapps/trafficsituation' done!"

  # deploy backend package
  cp "${app_package_dir}"/trafficsituation.war ${tomcat_root_dir}/webapps/
  #mv ehl-utb-trafficsituation-web trafficsituation
  echo ">>> deploy backend package to '${tomcat_root_dir}/webapps/' done!"

  # restart service
  sh ~/script/tomcat-restart.sh ${tomcatName} ${port}
  echo '>>> restart service done!'

  # recover front-end
  sleep 5
  \cp -rf "${app_backup_dir}"/trafficsituation/WEB-INF/classes/static/ ${tomcat_root_dir}/webapps/trafficsituation/WEB-INF/classes/
  sed -i "/axiosUrl/{s/[0-9]\{4\}/${port}/g}" ${tomcat_root_dir}/webapps/trafficsituation/WEB-INF/classes/static/static/config/js/url.js
  sed -i "/90.91:/{s/[0-9]\{4\}/${port}/g}" ${tomcat_root_dir}/webapps/trafficsituation/WEB-INF/classes/static/static/config/js/url.js
  echo ">>> recover front-end in '${tomcat_root_dir}/webapps/trafficsituation/WEB-INF/classes/' done!"

  echo ">>> build for ${branch} completed!"

else
  echo ">>> at least three params required!" 1>&2
  exit 1
fi

