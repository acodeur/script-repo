#!/bin/bash

. /etc/profile

if [ "$#" -ge 2 ]; then
  tomcatName=$1
  port=$2
  tomcatPath="/usr/local/software/${tomcatName}"
  binPath="$tomcatPath/bin"
  echo "[info][$(date +'%F %H:%M:%S')]正在监控tomcat，路径：$tomcatPath"
  pid=$(ps -ef | grep "${tomcatName}" | grep java | grep catalina | awk '{print $2}')
  if [ -n "$pid" ]; then
    echo "[info][$(date +'%F %H:%M:%S')]正在运行的tomcat进程为：$pid"
    echo "[info][$(date +'%F %H:%M:%S')]tomcat已经启动，准备使用shutdown命令关闭..."
    $binPath"/shutdown.sh"
    sleep 10
    pid=$(ps -ef | grep "${tomcatName}" | grep java | grep catalina | awk '{print $2}')
    if [ -n "$pid" ]; then
      echo "[info][$(date +'%F %H:%M:%S')]使用shutdown命令关闭失败，准备kill进程..."
      kill -9 $pid
      echo "[info][$(date +'%F %H:%M:%S')]kill进程完毕！"
      sleep 5
    else
      echo "[info][$(date +'%F %H:%M:%S')]使用shutdown命令关闭成功！"
    fi
  else
    echo "[info][$(date +'%F %H:%M:%S')]tomcat未启动！"
  fi
  echo "[info][$(date +'%F %H:%M:%S')]准备启动tomcat..."
  $binPath"/startup.sh"
  until [ $(curl --silent --write-out '%{response_code}' -o /dev/null "http://localhost:${port}") == 200 ]; do
      echo 'sleeping for 10 seconds'
      sleep 10
  done
  echo "[info][$(date +'%F %H:%M:%S')]tomcat就绪..."
else
  echo "at least two params required!" 1>&2
  exit 1
fi


