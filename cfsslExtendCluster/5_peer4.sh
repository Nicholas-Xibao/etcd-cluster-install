#!/bin/bash

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

set -e
function createExtendPeer () {
    echo_warning "使用方法: sh $0 \$1 \$2"
    if [ -z $1 ];then
    	echo_error '$1不能为空,$1为peerId'
    	exit 0
    fi
    
    if [ -z $2 ];then
    	echo_error '$2不能为空,$2为peerIP'
    	exit 0
    fi

    if [[ ! -f peer$1.pem || ! -f peer$1.crt ]];then
        sed -i "s#%node4_ip%#$2#g" json/peer-$1-csr.json
        #cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=peer ./json/peer-${1}-csr.json | cfssljson -bare peer${1}
        cfssl gencert -ca=./ssl/ca.pem -ca-key=./ssl/ca-key.pem -config=./json/ca-config.json -profile=peer ./json/peer-${1}-csr.json | cfssljson -bare peer${1}
        local peers
        echo_info "将peer$1.pem改名为peer$1.crt"
        if [ ! -f peer$1.crt ];then
            mv peer$1.pem peer$1.crt
        fi
        if [ ! -f peer$1-key.crt ];then
            mv peer$1-key.pem peer$1-key.crt
        fi
    fi
}

function movePeerCert () {
    if [ ! -f ssl/peer$1.crt ];then
	mv peer$1.crt ssl/
    fi
    if [ ! -f ssl/peer$1-key.crt ];then
	mv peer$1-key.crt ssl/
    fi
    if [ ! -f ssl/peer$1.csr ];then
	mv peer$1.csr ssl/
    fi
}

createExtendPeer $1 $2
movePeerCert $1
