#!/bin/bash

# This script is used to build frontend of ehl-utb-themeportrait-microservice

if [ "$#" -ge 3 ]; then
  jenkinsWorkspace="$1"
  branch="$2"
  port="$3"
  case $branch in
  *-dev-feature)
    echo ">>> match <$branch>"
    module=${branch%%-dev-feature}
    tomcatName="tomcat-${module}-archive"
    ;;
  develop-feature-temp1)
    echo ">>> match <$branch>"
    tomcatName="tomcat-event-archive"
    ;;
  develop-feature | develop | master | milestone-demo)
    echo ">>> match <$branch>"
    tomcatName='apache-tomcat-9.0.27'
    ;;
  *)
    echo ">>> Unsupported branch: <$branch>"
    exit 2
    ;;
  esac

  # initialize variables
  remote_package_dir="${jenkinsWorkspace}"
  app_package_dir="/root/apps/${branch}/dist"
  tomcat_frontend_root_dir="/usr/local/software/${tomcatName}/webapps/ehl-utb-themeportrait-web/WEB-INF/classes/static"

  # mkdir if not exist
  if [ ! -d ${app_package_dir} ]; then mkdir -p ${app_package_dir}; fi

  # prepare frontend package
  rm -rf "${app_package_dir:?}"/*
  scp -i ~/.ssh/id_rsa_172.38.90.57 -r root@172.38.90.57:"${remote_package_dir}/dist/*" "${app_package_dir}"
  echo ">>> transfer frontend package to '${app_package_dir}/' done!"

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

  # update backend api port
  sed -i "/axiosUrl/{s/[0-9]\{4\}/${port}/g}" ${tomcat_frontend_root_dir}/static/config/js/url.js
  sed -i "/90.91:/{s/[0-9]\{4\}/${port}/g}" ${tomcat_frontend_root_dir}/static/config/js/url.js
  echo ">>> update backend api port in '${tomcat_frontend_root_dir}/static/config/js/url.js' done!"

  echo ">>> build for ${branch} completed!"

else
  echo ">>> at least three params required!" 1>&2
  exit 1
fi
