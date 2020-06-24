#!/bin/bash


. ./globalClusterInfo.sh
clusterArray


clientCertNoHost="clientNoHost"

function printInfo (){
    echo -e "\e[1;32m[$(date +%Y-%m-%d' '%H:%M:%S)] [INFO] [$1]\e[0m"
}
function printError (){
    echo -e "\e[1;31m[$(date +%Y-%m-%d' '%H:%M:%S)] [ERROR] [$1]\e[0m"
}
function printWarning (){
    echo -e "\e[1;33m[$(date +%Y-%m-%d' '%H:%M:%S)] [WARNING] [$1]\e[0m"
}
function printFatal (){
    echo -e "\e[1;41m[$(date +%Y-%m-%d' '%H:%M:%S)] [FATAL] [$1]\e[0m"
}
# 开启集群外部pki安全认证
# 外部的意思在本篇就是使用 etcdtl来访问，etcdctl 就是外部客户端。如果k8s的apiserver访问etcd，那么apiserver就是客户端
function createRootCA () {
    if [ -f ssl/ca.crt ];then
	printError "已存在ca证书"
	exit 0
    fi
    if [ ! -f ./ssl/ca.pem ];then
        printInfo "开始生成ca证书"
        cfssl gencert -initca ./json/ca-csr.json | cfssljson -bare ca
        mkdir ssl/ &>/dev/null
	    printFatal "mv ca.csr ca-key.pem ca.pem到ssl/"
	    mv ca.csr ca-key.pem ca.pem ssl/
        local reNameCa
        for reNameCa in `ls ssl/ca*.pem`
        do
	    printInfo "将${reNameCa}改名为${reNameCa%%.pem}.crt"
            mv $reNameCa ${reNameCa%%.pem}.crt

        done
    else
        printFatal "已有CA"
        exit 0
    fi
    # 只需要将ca.pem发给其他node节点即可
}

printInfo "服务器列表: `echo ${server_arrays[@]}`"

function createThreeEtcdServerCert () {
    srvNum=${#server_arrays[@]}
	echo $srvNum
    # 临时json目录
    if [ ! -d json/temp ];then
	mkdir json/temp
    fi

    local snum
    if [ $srvNum -eq 3 ];then
	    printInfo "批量替换node1_ip node2_ip node3_ip json/*.json"
        for snum in `seq ${srvNum}`
        do
	        if [ $snum -eq 1 ];then
                # server 1
		        if [ ! -f json/server-${snum}-csr.json ];then
	                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
		            cp json/server-template-csr.json json/server-${snum}-csr.json
                            sed -i "s#%clusterIPaddr%#${server_arrays[0]}#g" json/server-${snum}-csr.json
                            sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
			else
			    echo -e \e"[41mokokokjson/server-${snum}-csr.json\e[0m"
			    mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.`date +%Y%m%d%H%M%S`.json
			    #rm -f json/server-${snum}-csr.json
                            printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
                            cp json/server-template-csr.json json/server-${snum}-csr.json
                            sed -i "s#%clusterIPaddr%#${server_arrays[0]}#g" json/server-${snum}-csr.json
                            sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                        fi
                # peer 1
                if [ ! -f json/peer-${snum}-csr.json ];then
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[0]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
                else
		    mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/peer-${snum}-csr.json
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[0]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
                fi
	        fi

	        if [ $snum -eq 2 ];then
                    if [ ! -f json/server-${snum}-csr.json ];then
                        printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                        cp json/server-template-csr.json json/server-${snum}-csr.json
                        sed -i "s#%clusterIPaddr%#${server_arrays[1]}#g" json/server-${snum}-csr.json
                        sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
		    else
                        mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                        rm -f json/server-${snum}-csr.json
                        printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                        cp json/server-template-csr.json json/server-${snum}-csr.json
                        sed -i "s#%clusterIPaddr%#${server_arrays[1]}#g" json/server-${snum}-csr.json
                        sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                    fi
                    if [ ! -f json/peer-${snum}-csr.json ];then
                        printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                        cp json/peer-template-csr.json json/peer-${snum}-csr.json
                        sed -i "s#%peerIPaddr%#${server_arrays[1]}#g" json/peer-${snum}-csr.json
                        sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
		    else
		        mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                        rm -f json/peer-${snum}-csr.json
                        printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                        cp json/peer-template-csr.json json/peer-${snum}-csr.json
                        sed -i "s#%peerIPaddr%#${server_arrays[1]}#g" json/peer-${snum}-csr.json
                        sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                    fi
	       fi

            if [ $snum -eq 3 ];then
                if [ ! -f json/server-${snum}-csr.json ];then
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[2]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
		else
                    mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/server-${snum}-csr.json
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[2]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                fi
                if [ ! -f json/peer-${snum}-csr.json ];then
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[2]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
		else
                    mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[2]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                fi
           fi
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-${snum}-csr.json | cfssljson -bare server${snum}
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=peer ./json/peer-${snum}-csr.json | cfssljson -bare peer${snum} 
            if [[ -f server${snum}.pem && -f peer${snum}.pem ]];then
                printInfo "生成server${snum}.pem和peer${snum}.pem成功"
            else
                printFatal "生成server${snum}.pem或peer${snum}.pem失败"
                exit 0
            fi
        done
    
    elif [ $srvNum -eq 5 ];then
        printInfo "批量替换node1_ip node2_ip node3_ip node4_ip node5_ip json/*.json"
        for snum in `seq ${srvNum}`
        do
            if [ $snum -eq 1 ];then
                # server 1
                if [ ! -f json/server-${snum}-csr.json ];then
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[0]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                else
		    mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/server-${snum}-csr.json
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[0]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                fi
                # peer 1
                if [ ! -f json/peer-${snum}-csr.json ];then
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[0]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
                else
                    mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/peer-${snum}-csr.json
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[0]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[0]}`中的IP地址"
                fi
            fi

            if [ $snum -eq 2 ];then
                if [ ! -f json/server-${snum}-csr.json ];then
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[1]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
		else
                    mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/server-${snum}-csr.json
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[1]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                fi
                if [ ! -f json/peer-${snum}-csr.json ];then
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[1]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                else
                    mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[1]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[1]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                fi
           fi

            if [ $snum -eq 3 ];then
                if [ ! -f json/server-${snum}-csr.json ];then
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[2]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
		else
                    mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/server-${snum}-csr.json
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[2]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                fi
                if [ ! -f json/peer-${snum}-csr.json ];then
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[2]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
		else
                    mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[2]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[2]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                fi
            fi
            if [ $snum -eq 4 ];then
                if [ ! -f json/server-${snum}-csr.json ];then
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[3]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[3]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
		else
                    mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/server-${snum}-csr.json
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[3]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[3]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                fi
                if [ ! -f json/peer-${snum}-csr.json ];then
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[3]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[3]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
		else
                    mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[3]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[3]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                fi
            fi
            if [ $snum -eq 5 ];then
                if [ ! -f json/server-${snum}-csr.json ];then
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[4]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[4]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
		else
                    mv json/server-${snum}-csr.json json/temp/server-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/server-${snum}-csr.json
                    printInfo "开始生成server${snum}证书并依次绑定`echo ${server_arrays[4]}`中的IP地址"
                    cp json/server-template-csr.json json/server-${snum}-csr.json
                    sed -i "s#%clusterIPaddr%#${server_arrays[4]}#g" json/server-${snum}-csr.json
                    sed -i "s#%clusterIDS%#$snum#g" json/server-${snum}-csr.json
                fi
                if [ ! -f json/peer-${snum}-csr.json ];then
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[4]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[4]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
		else
                    mv json/peer-${snum}-csr.json json/temp/peer-${snum}-csr.json.$(date +%Y%m%d%H%M%S)
                    rm -f json/peer-${snum}-csr.json
                    printInfo "开始生成peer${snum}证书并依次绑定`echo ${server_arrays[4]}`中的IP地址"
                    cp json/peer-template-csr.json json/peer-${snum}-csr.json
                    sed -i "s#%peerIPaddr%#${server_arrays[4]}#g" json/peer-${snum}-csr.json
                    sed -i "s#%peerIDS%#$snum#g" json/peer-${snum}-csr.json
                fi
           fi
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-${snum}-csr.json | cfssljson -bare server${snum}
            cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=peer ./json/peer-${snum}-csr.json | cfssljson -bare peer${snum} 
            if [[ -f server${snum}.pem && -f peer${snum}.pem ]];then
                printInfo "生成server${snum}.pem和peer${snum}.pem成功"
            else
                printFatal "生成server${snum}.pem或peer${snum}.pem失败"
                exit 0
            fi
        done
    fi
    
    # 对server证书重命名
    local reNameServer reNamePeer
    for reNameServer in `ls server*.pem`
    do
        printInfo "将${reNameServer}改名为${reNameServer%%.pem}.crt"
        mv ${reNameServer} ${reNameServer%%.pem}.crt
    done
	 
    # 对peer证书重命名
    for reNamePeer in `ls peer*.pem`
    do
        mv ${reNamePeer} ${reNamePeer%%.pem}.crt
    done

    #rm -f  json/peer-{1..5}-csr.json
    #rm -f  json/server-{1..5}-csr.json
}

function createClientCert () {
    if [ ! -f clientNoHost.pem ];then
	printInfo "开始生成没有IP绑定的客户端证书"
        if ( cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=client ./json/clientNoHost.json | cfssljson -bare clientNoHost );then
	    printInfo "客户端证书生成完成"
	
	for tempClient in `ls clientNoHost*.pem`
        do
            mv $tempClient ${tempClient%%.pem}.crt
        done
else
	    printError "客户端证书生成失败"
            exit 5
    fi
fi
}

function moveCertToSslPath () {
    printFatal "mv client* server* peer* ---> ssl/"
    mv  client* peer* server* ssl/
    printFatal "修改ssl/所有权限为400"
    chmod 400 ssl/*
    printWarning "恭喜: 所有证书生成完成"
    mkdir -p /opt/$(date +%Y%m%d%H%M)_cert &>/dev/null
    cp -r ssl /opt/$(date +%Y%m%d%H%M)_cert
}

function createALLLLL () {
    createRootCA
    createThreeEtcdServerCert
    createClientCert
    moveCertToSslPath
}
