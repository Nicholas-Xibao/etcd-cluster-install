#!/bin/bash


		
  sed -i "s#%node1_ip%#${server_arrays[0]}#g" json/*.json
  sed -i "s#%node2_ip%#${server_arrays[1]}#g" json/*.json
  sed -i "s#%node3_ip%#${server_arrays[2]}#g" json/*.json

  for i in `seq 3`
  do
      cfssl gencert -ca=ca.crt -ca-key=ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-${i}-csr.json | cfssljson -bare server${i}
      if [ -f server$i.pem ];then
	  echo -e "\e[32mInfo: server$i.pem生成成功\e[0m"
      else
	  echo -e "\e[31mError: server$i.pem生成失败\e[0m"
	  exit 0
      fi
  done

#cfssl gencert -ca=ca.crt -ca-key=ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-4-csr.json | cfssljson -bare server4

