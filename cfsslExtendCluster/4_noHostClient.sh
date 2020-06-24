#!/bin/bash


if [ ! -f client.pem ];then
    cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=client ./json/clientNoHost.json | cfssljson -bare client

fi

