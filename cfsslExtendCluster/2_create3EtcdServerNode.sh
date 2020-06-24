#!/bin/bash


. ./globalClusterInfo.sh
clusterArray


clientCertNoHost="clientNoHost"

function echo_info (){
    echo -e "\e[1;32m[$(date +%Y-%m-%d' '%H:%M:%S)] [INFO] [$1]\e[0m"
}

function echo_error (){
    echo -e "\e[1;31m[$(date +%Y-%m-%d' '%H:%M:%S)] [ERROR] [$1]\e[0m"
}

function echo_warning (){
    echo -e "\e[1;33m[$(date +%Y-%m-%d' '%H:%M:%S)] [WARNING] [$1]\e[0m"
}

function echo_fatal (){
    echo -e "\e[1;41m[$(date +%Y-%m-%d' '%H:%M:%S)] [FATAL] [$1]\e[0m"
}

# 开启集群外部pki安全认证
# 外部的意思在本篇就是使用 etcdtl来访问，etcdctl 就是外部客户端。如果k8s的apiserver访问etcd，那么apiserver就是客户端
function createRootCA () {
    if [[ ! -f ./ssl/ca.pem ]];then
        echo_info "开始生成ca证书"
        cfssl gencert -initca ./json/ca-csr.json | cfssljson -bare ca
        mkdir ssl/ &>/dev/null
	echo_fatal "mv ca.csr ca-key.pem ca.pem到ssl/"
	mv ca.csr ca-key.pem ca.pem ssl/
        local reNameCa
        for reNameCa in `ls ssl/ca*.pem`
        do
	    echo_info "将${reNameCa}改名为${reNameCa%%.pem}.crt"
            mv $reNameCa ${reNameCa%%.pem}.crt

        done
    else
        echo_fatal "已有CA"
        exit 0
    fi
    # 只需要将ca.pem发给其他node节点即可
}

echo_info "服务器列表: `echo ${server_arrays[@]}`"
function createThreeEtcdServerCert () {
    srvNum=${#server_arrays[@]}
    local snum
    if [[ $srvNum -eq 3 ]];then
	echo_info "批量替换node1_ip node2_ip node3_ip json/*.json"
        sed -i "s#%node1_ip%#${server_arrays[0]}#g" json/*.json
        sed -i "s#%node2_ip%#${server_arrays[1]}#g" json/*.json
        sed -i "s#%node3_ip%#${server_arrays[2]}#g" json/*.json
        for snum in `seq ${srvNum}`
        do
	    if [ $snum -eq 1 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
	    fi
	    if [ $snum -eq 2 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
	    fi
	    if [ $snum -eq 3 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
	    fi
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-${snum}-csr.json | cfssljson -bare server${snum}
	    if [ $snum -eq 1 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
	    fi
	    if [ $snum -eq 2 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
	    fi
	    if [ $snum -eq 3 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
	    fi
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=peer ./json/peer-${snum}-csr.json | cfssljson -bare peer${snum} 
            if [[ -f server${snum}.pem && -f peer${snum}.pem ]];then
                echo_info "生成server${snum}.pem和peer${snum}.pem成功"
            else
                echo_fatal "生成server${snum}.pem或peer${snum}.pem失败"
                exit 0
            fi
        done
    elif [[ $srvNum -eq 5 ]];then
	echo_info "批量替换node1-5_ip json/*.json"
        sed -i "s#%node1_ip%#${server_arrays[0]}#g" json/*.json
        sed -i "s#%node2_ip%#${server_arrays[1]}#g" json/*.json
        sed -i "s#%node3_ip%#${server_arrays[2]}#g" json/*.json
        sed -i "s#%node4_ip%#${server_arrays[3]}#g" json/*.json
        sed -i "s#%node5_ip%#${server_arrays[4]}#g" json/*.json
        for snum in `seq ${srvNum}`
        do
	    if [ $snum -eq 1 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
	    fi
	    if [ $snum -eq 2 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
	    fi
	    if [ $snum -eq 3 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
	    fi
	    if [ $snum -eq 4 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[3]}`中的IP地址"
	    fi
	    if [ $snum -eq 5 ];then
	        echo_info "开始生成server${snum}证书并依次绑定`echo ${server_arrays[4]}`中的IP地址"
	    fi
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-${snum}-csr.json | cfssljson -bare server${snum}
	    if [ $snum -eq 1 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
	    fi
	    if [ $snum -eq 2 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
	    fi
	    if [ $snum -eq 3 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
	    fi
	    if [ $snum -eq 4 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[3]}`中的IP地址"
	    fi
	    if [ $snum -eq 5 ];then
	        echo_info "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[4]}`中的IP地址"
	    fi
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=peer ./json/peer-${snum}-csr.json | cfssljson -bare peer${snum}
            if [[ -f server${snum}.pem && -f peer${snum}.pem ]];then
                echo_info "生成server${snum}.pem和peer${snum}.pem成功"
            else
                echo_fatal "生成server${snum}.pem或peer${snum}.pem失败"
                exit 0
            fi
        done
    fi
    
    # 对server证书重命名
    local reNameServer reNamePeer
    for reNameServer in `ls server*.pem`
    do
        echo_info "将${reNameServer}改名为${reNameServer%%.pem}.crt"
        mv ${reNameServer} ${reNameServer%%.pem}.crt
    done
	 
    # 对peer证书重命名
    for reNamePeer in `ls peer*.pem`
    do
        mv ${reNamePeer} ${reNamePeer%%.pem}.crt
    done
}

function createClientCert () {
    if [ ! -f clientNoHost.pem ];then
	echo_info "开始生成没有IP绑定的客户端证书"
        if ( cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=client ./json/clientNoHost.json | cfssljson -bare clientNoHost );then
	    echo_info "客户端证书生成完成"
	
	for tempClient in `ls clientNoHost*.pem`
        do
            mv $tempClient ${tempClient%%.pem}.crt
        done
else
	    echo_error "客户端证书生成失败"
            exit 5
    fi
fi
}

function moveCertToSslPath () {
    echo_fatal "mv client* server* peer* ---> ssl/"
    mv  client* peer* server* ssl/
    echo_fatal "修改ssl/所有权限为400"
    chmod 400 ssl/*
    echo_warning "恭喜: 所有证书生成完成"
    mkdir -p /opt/$(date +%Y%m%d%H%M)_cert &>/dev/null
    cp -r ssl /opt/$(date +%Y%m%d%H%M)_cert
}
#cfssl gencert -ca=ca.crt -ca-key=ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-4-csr.json | cfssljson -bare server4
createRootCA
createThreeEtcdServerCert
createClientCert
moveCertToSslPath
