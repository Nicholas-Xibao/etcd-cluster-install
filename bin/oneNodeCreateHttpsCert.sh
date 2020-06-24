#!/usr/bin/env bash
#Program:
#		获取node节点信息
#author: yinshx
#mail: yinshx@yonyou.com
#date: 2019/5/31
#version: 1.0
. ./globalClusterInfo.sh
clusterArray
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

#创建key
function create_etcd_key () {
	cd ../crt/
	openssl genrsa -out ca.key 2048
	openssl req -x509 -new -nodes -key ca.key -subj "/CN=cn" -days 3650 -out ca.crt 
	cd ${old_dir}
    pwd
}

##创建证书请求配置文件
#function create_crt_conf () {
#
#        cat > ../crt/etcd-ca.conf <<EOF
#[ req ]
#default_bits = 2048
#prompt = no
#default_md = sha256
#req_extensions = req_ext
#distinguished_name = dn
#
#[ dn ]
#C = CN
#ST = beijing
#L = beijing
#O = yonyou
#OU = yonyou
#CN = www.yonyou.com
#
#[ req_ext ]
#subjectAltName = @alt_names
#
#[ alt_names ]
#DNS.1 = localhost
#DNS.2 = etcd1
#DNS.3 = etcd2
#DNS.4 = etcd3
#IP.1 = 127.0.0.1
#IP.2 = etcd_node1
#IP.3 = etcd_node2
#IP.4 = etcd_node3
#
#[ v3_ext ]
#authorityKeyIdentifier=keyid,issuer:always
#basicConstraints=CA:FALSE
#keyUsage=keyEncipherment,dataEncipherment
#extendedKeyUsage=serverAuth,clientAuth
#subjectAltName=@alt_names
#EOF
#}
#创建证书请求配置文件
function create_crt_conf () {

	cat > ../crt/etcd-ca.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
    
[ dn ]
C = CN
ST = beijing
L = beijing
O = yonyou
OU = yonyou
CN = www.yonyou.com
    
[ req_ext ]
subjectAltName = @alt_names
    
[ alt_names ]
DNS.1 = localhost
DNS.2 = etcd1
IP.1 = 127.0.0.1
IP.2 = etcd_node1
    
[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF
}

#替换一些IP信息
function replaceip () {
	cd ${create_crt_dir}
	sed -i "s#etcd_node1#${server_arrays[0]}#g" etcd-ca.conf
	#sed -i "s#etcd_node2#${server_arrays[1]}#g" etcd-ca.conf
	#sed -i "s#etcd_node3#${server_arrays[2]}#g" etcd-ca.conf

}


function createcrt () {
#生成密钥
openssl genrsa -out etcd.key 2048
#生成证书签发请求(certificate signing request)
openssl req -new -key etcd.key -out etcd.csr -config etcd-ca.conf
#生成证书
openssl x509 -req -in etcd.csr -CA ca.crt -CAkey ca.key \
-CAcreateserial -out etcd.crt -days 3650 \
-extensions v3_ext -extfile etcd-ca.conf

#验证证书
crt_status=`openssl verify -CAfile ca.crt etcd.crt | awk '{print $2}'`
        if [[ ${crt_status} == "ok" || ${crt_status} == "OK" ]];then
            echo "etcd证书生成成功"
	else
            echo "etcd证书生成失败"
            exit 3
    fi
}

function sendcrt () {
	cd ${shell_dir}
	if [ ! -e ${etcd_crt_path}/ca.crt ];then
		cp ../crt/ca.crt ${etcd_crt_path}/
else
		echo "${etcd_crt_path}已存在ca.crt"
		exit 4
fi 

	if [ ! -e ${etcd_crt_path}/etcd.crt ];then
		cp ../crt/etcd.crt ${etcd_crt_path}/
else
		echo "${etcd_crt_path}已存在etcd.crt"
		exit 5
fi

	if [ ! -e ${etcd_crt_path}/etcd.key ];then
		cp ../crt/etcd.key ${etcd_crt_path}/
else
		echo "${etcd_crt_path}已存在etcd.key"
		exit 6
fi
}

function createOneNodeCert () {
	create_etcd_crt_path
	create_etcd_key
	create_crt_conf
	replaceip
	createcrt
	sendcrt
}
