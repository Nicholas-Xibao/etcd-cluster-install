#!/bin/bash


if [ ! -f client.pem ];then
    cfssl gencert -ca=ca.crt -ca-key=ca-key.crt -config=./json/ca-config.json -profile=client ./json/client.json | cfssljson -bare client

fi

