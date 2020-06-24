#!/bin/bash


# 开启集群外部pki安全认证
# 外部的意思在本篇就是使用 etcdtl来访问，etcdctl 就是外部客户端。如果k8s的apiserver访问etcd，那么apiserver就是客户端
function createRootCA () {
    if [[ ! -f ca.csr && ! -f ca.pem && ! -f ca-key.pem ]];then
        echo "开始生成ca证书"
        cfssl gencert -initca ./json/ca-csr.json | cfssljson -bare ca
    else
        echo "已有CA"
        exit 0
    fi
    mkdir ssl/ &>/dev/null
    # 只需要将ca.pem发给其他node节点即可
    
    if [[ ! -f ssl/ca.csr && ! -f ssl/ca.pem && ! -f ssl/ca-key.pem ]];then
    	cp ca.csr ca-key.pem ca.pem ssl/
    fi
    local reNameCa
    for reNameCa in `ls ca*.pem`
    do
        cp $reNameCa ${reNameCa%%.pem}.crt

    done
}
    createRootCA
