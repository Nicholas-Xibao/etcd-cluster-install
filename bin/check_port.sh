#!/bin/bash
#Program:
#               检查端口是否占用
#mail: yinshx@yonyou.com
#date: 2019/6/3

#2379
#2380

#端口数组


#端口数组
etcdPortArray=(2379 2380)
tempPortFile=/tmp/usedPort.txt

function probePort () {
    local usedPortTotal=0
    # 判断 如果存在 就删除
    if [ -f $tempPortFile ];then
        rm -f $tempPortFile
    fi
    for usedPort in ${etcdPortArray[@]}
    do
        if ( netstat -atnpu | egrep -i 'listen' | awk '{print $4}' | grep ${usedPort} &>/dev/null );then
            processName=`netstat -atnpu | egrep "\b${usedPort}\b" | grep -i listen  | awk -F/ '{print $NF}'`
            echo -e "\e[31m[$(date +%Y-%m-%d' '%H:%M:%S)] 端口---> <${usedPort}>已被占用,请解除占用后执行该脚本\e[0m" | tee -a $tempPortFile #追加到这个文件中
            used_pid=`netstat -atnpu | grep -i listen | egrep "\b${usedPort}\b" | awk '{print $7}' | egrep -o '[0-9]{1,3}{1,6}'`
            echo -e "\e[31m[$(date +%Y-%m-%d' '%H:%M:%S)] 端口---> <${usedPort}>被占用，进程名称[ $processName ]\e[0m"
            echo -e "\e[31m[$(date +%Y-%m-%d' '%H:%M:%S)] 端口---> <${usedPort}>被占用，进程id为[ ${used_pid} ]\e[0m"
            usedPortArray[$usedPortTotal]=${usedPort}
            let usedPortTotal++
      else
            echo -e "\e[32m[$(date +%Y-%m-%d' '%H:%M:%S)] ${usedPort}未被占用\e[0m"
      fi
    done
    if [ ${#usedPortArray[@]} -gt 0 ];then
        echo -e "\e[31m[$(date +%Y-%m-%d' '%H:%M:%S)] 共有[ ${#usedPortArray[@]} ]个端口被占用,请解除占用后执行该脚本\e[0m"
        exit 2
  else
        echo -e "\e[32m[$(date +%Y-%m-%d' '%H:%M:%S)] 所有服务端口均为被占用\e[0m"
  fi
}
