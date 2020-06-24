#!/usr/bin/env bash
#Program:
#		获取node节点信息
#author: yinshx
#mail: yinshx@yonyou.com
#date: 2019/5/31
#version: 1.0
. ./globalClusterInfo.sh 
old_dir=`pwd`
shell_dir=$(cd "$(dirname "$0")"; pwd)
etcd_crt_path="/etc/ssl/etcd/ssl"

create_crt_dir="../crt/"

#创建证书路径
function create_etcd_crt_path () {
    if [ ! -e ${etcd_crt_path} ];then
        mkdir -p ${etcd_crt_path} &>/dev/null 
    fi
    if [ ! -e ${etcd_data_path} ];then
        mkdir -p ${etcd_data_path} &>/dev/null
    fi 
}


function publish_crt () {
    cd ../cfsslExtendCluster/
    sh extandCluster.sh -A
    sh extandCluster.sh -P
    cd ${shell_dir}
    \cp -r ../cfsslExtendCluster/ssl /etc/ssl/etcd/
}

function create_crt_fun () {
	create_etcd_crt_path
	publish_crt
}
#create_crt_fun
