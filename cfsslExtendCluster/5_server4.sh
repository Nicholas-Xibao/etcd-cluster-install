cfssl gencert -ca=./ssl/ca.crt -ca-key=./ssl/ca-key.crt -config=./json/ca-config.json -profile=server ./json/server-4-csr.json | cfssljson -bare server4
