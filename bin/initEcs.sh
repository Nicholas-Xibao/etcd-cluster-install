#!/bin/bash
#Program:
#		初始化机器
#	5 node
#author: yinshx
#mail: yinshx@yonyou.com
#date: 2019/5/31

. ./check_port.sh
. ./appendHosts.sh

#----------------------variables----------------------------#



function printInfo (){
    echo -e "\e[1;35m [$(date +%Y-%m-%d' '%H:%M:%S)] [INFO] [$1]\e[0m"
}

function printError (){
    echo -e "\e[1;31m [$(date +%Y-%m-%d' '%H:%M:%S)] [ERROR] [$1]\e[0m"
}

function printWarning (){
    echo -e "\e[1;34m [$(date +%Y-%m-%d' '%H:%M:%S)] [WARNING] [$1]\e[0m"
}

function printFatal (){
    echo -e "\e[1;41m [$(date +%Y-%m-%d' '%H:%M:%S)] [FATAL] [$1]\e[0m"
}

function getNodeInfo () {
        local nodeMax=${#server_arrays[@]}
        local l=1
        while [ $l -le $nodeMax ]
        do
            serverArrayIndex=$[l - 1]
            echo "${server_arrays[$serverArrayIndex]} server${l}"
            let l++
        done
}

#检查磁盘空间/data/ > 100G 
function checkDiskMount (){
    if (! df -h /data/ | egrep '/data\b' &>/dev/null);then
        echo -e "\e[1;41m[$(date +%Y-%m-%d' '%H:%M:%S)] [ERROR] [没有/data/挂载点]\e[0m"
        exit 100
    fi
    df -h /data/ | egrep '/data\b' > /tmp/.mountPoint.txt
    diskTotal=`awk '{print $2}' /tmp/.mountPoint.txt | tr -d 'G'`
    freeDisk=(`awk '{print $4,$5}' /tmp/.mountPoint.txt | tr -d 'G'`)
    freeB=`echo $[ 100 - $(awk '{print $5}'  /tmp/.mountPoint.txt | tr -d '%')]`

#data分区小于100G退出

        if [ ${freeDisk[0]} -lt 100 ];then
          logger WARNING  `echo -e "\e[1;32m[$(date +%Y-%m-%d' '%H:%M:%S)] [WARNING] [/data/挂载点磁盘空间:${diskTotal}G]\e[0m\e[1;5;41m[可用磁盘空间=${freeDisk[0]}G][可用磁盘百分比=${freeB}%]\e[0m"`
          echo -e "\e[1;32m[$(date +%Y-%m-%d' '%H:%M:%S)] [WARNING] [/data/挂载点磁盘空间:${diskTotal}G]\e[0m\e[1;5;41m[可用磁盘空间=${freeDisk[0]}G][>可用磁盘百分比=${freeB}%]\e[0m"
          exit 102
          #可根据自己实际报警方式进行报警
      else
          logger INFO `echo -e "\e[1;32m[$(date +%Y-%m-%d' '%H:%M:%S)] [INFO] [/data/挂载点磁盘空间:${diskTotal}G]\e[0m\e[1;35m[可用磁盘空间=${freeDisk[0]}G][可用磁盘百分比=${freeB}%]\e[0m"`
     echo -e "\e[1;32m[$(date +%Y-%m-%d' '%H:%M:%S)] [INFO] [/data/挂载点磁盘空间:${diskTotal}G]\e[0m\e[1;35m[可用磁盘空间=${freeDisk[0]}G][可用磁盘百>分比=${freeB}%]\e[0m"
      fi

}

#将防火墙和selinux关闭选项加入rc.local 每次机器启动都会执行一遍

function shutdown_firewall_selinux () {

    systemctl stop firewalld && systemctl disable firewalld
    
    sed -i '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux && setenforce 0

    if ( ! grep 'firewall' /etc/rc.d/rc.local );then
		echo "
        for stop_num in 1 2 3
        do
            systemctl stop firewalld && systemctl disable firewalld
            setenforce 0
        done
        " >>/etc/rc.d/rc.local

        chmod +x /etc/rc.d/rc.local
    fi
    #systemctl stop NetworkManager &>/dev/null systemctl disable NetworkManager &>/dev/null

}

function check_kernel () {

    kernel_version=`uname -r | awk -F '.' '{print $1}'`
    if [ $kernel_version -lt 4 ];then
        echo -e "\e[1;45m警告:\e[0m"
        echo -e "\e[1;41m\t[内核版本]<4\e[0m"
        echo -e "\e[1;42m\t[docker overlay2驱动需将内核升级为4.0+]\e[0m"
        echo -e "\e[1;41m\t请使用/data/developercenter_enterprise/script/tools/update_kernel/update_kernel_418/或/data/developercenter_enterprise/script/tools/update_kernel/update_kernel_420/下升级脚本进行升级，升级后会进行重启机器\e[0m"
        exit 1
    fi

}

function modify_kernel(){

    cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
fs.file-max=99999
kernel.pid_max = 99999
net.ipv4.tcp_tw_reuse = 0
net.ipv4.ip_local_port_range = 1024 65535
EOF
    sysctl -p

}

function modify_ulimit(){

    cat >> /etc/security/limits.conf << EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
    ulimit -SHn 102400

}

# 检测系统版本
function check_system_version () {

    local s=
    local sys_pass=false
    echo "本安装版仅适用于 Linux CentOS 7 操作系统"
    if [ -f /etc/redhat-release ]; then
        s=`cat /etc/redhat-release |grep 7\..*|grep -i centos`
        if [ -z "${s}" ]; then
            sys_pass=false
        else
            sys_pass=true
        fi
    else
        sys_pass=false
    fi
    if ! ${sys_pass}; then
        echo "错误！当前非 CentOS 7 操作系统！"
        exit 1
    fi

}

function reset_machine (){
	probePort
        appendHost
	check_system_version
	#checkDiskMount
	#check_kernel
	shutdown_firewall_selinux
	modify_ulimit
	modify_kernel
	getNodeInfo

}
