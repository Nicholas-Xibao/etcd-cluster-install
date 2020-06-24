#!/usr/bin/env bash
#Program:
#		获取所有服务器ip
#author: yinshx
#date: 2019/5/31

function printInfo (){
    echo -e "\e[1;32m[$(date +%Y-%m-%d' '%H:%M:%S)] [INFO] [$1]\e[0m"
}

function printError (){
    echo -e "\e[1;31m[$(date +%Y-%m-%d' '%H:%M:%S)] [ERROR] [$1]\e[0m"
}

function printWarning (){
    echo -e "\e[1;34m[$(date +%Y-%m-%d' '%H:%M:%S)] [WARNING] [$1]\e[0m"
}

function printFatal (){
    echo -e "\e[1;41m[$(date +%Y-%m-%d' '%H:%M:%S)] [FATAL] [$1]\e[0m"
}

shell_dir=$(cd "$(dirname "$0")"; pwd)
old_dir=$PWD
etcdConfig="/etc/etcd/etcd.conf"
etcdService="/usr/lib/systemd/system"
etcdCommandPath="../tools"
etcdCommandPath="/usr/local/bin"
EtcdServiceName="etcd.service"

backupDataPath="/data/backup_etcd"
etcdConfPath="/etc/etcd"
ca_conf="/etc/ssl/etcd/ssl/ca.crt"
crt_conf="/etc/ssl/etcd/ssl/clientNoHost.crt"
key_conf="/etc/ssl/etcd/ssl/clientNoHost-key.crt"
etcdCertPath='/etc/ssl/etcd/ssl'
etcdDataPath="/data/etcd/data"

function clusterArray (){
	server_arrays=(172.17.174.40 172.17.174.41 172.17.174.42 172.17.174.43 172.17.174.44)
	#server_arrays=(172.17.174.40)
	etcd_port_array=(2379 2380)
}
	clusterArray
