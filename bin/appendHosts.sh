#!/bin/bash
#Program:
#               检查端口是否占用
#mail: yinshx@yonyou.com
#date: 2019/6/3

#2379
#2380

#add hosts
#在globalClusterInfo.sh 执行后执行 
. ./globalClusterInfo.sh 

serviceNN="etcd"
function appendHost () {
        local nodeMax=${#server_arrays[@]}
        local l=1
        while [ $l -le $nodeMax ]
        do
            serverArrayIndex=$[l - 1]
	    if ( ! grep -i "$serviceNN$l" /etc/hosts &>/dev/null );then
		printInfo "追加host ${server_arrays[$serverArrayIndex]} ${serviceNN}${l} /etc/hosts"
                echo "${server_arrays[$serverArrayIndex]} ${serviceNN}${l}" >>/etc/hosts
	    else
		printError "/etc/hosts中已经存在${server_arrays[$serverArrayIndex]} ${serviceNN}${l}"
	    fi
            let l++
        done
	cat /etc/hosts
}
