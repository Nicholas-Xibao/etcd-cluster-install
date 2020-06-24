#!/bin/bash

for i in `seq 3`
do
    cfssl gencert -ca=ca.crt -ca-key=ca-key.crt -config=./json/ca-config.json -profile=peer ./json/peer-${i}-csr.json | cfssljson -bare peer${i}
done
