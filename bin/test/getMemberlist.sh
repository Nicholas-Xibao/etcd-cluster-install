ETCDCTL_API=2 /usr/local/bin/etcdctl \
    --endpoints=https://172.17.174.40:2379,https://172.17.174.41:2379,https://172.17.174.42:2379 \
    --ca-file="/etc/ssl/etcd/ssl/ca.crt" \
    --cert-file="/etc/ssl/etcd/ssl/clientNoHost.crt" \
    --key-file="/etc/ssl/etcd/ssl/clientNoHost-key.crt" \
    member list
