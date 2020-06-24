ETCDCTL_API=3 /usr/local/bin/etcdctl \
    --endpoints=https://172.17.174.40:2379,https://172.17.174.41:2379,https://172.17.174.42:2379,https//172.17.174.43:2379,https://172.17.174.44:2379 \
    --cacert="/etc/ssl/etcd/ssl/ca.crt" \
    --cert="/etc/ssl/etcd/ssl/clientNoHost.crt" \
    --key="/etc/ssl/etcd/ssl/clientNoHost-key.crt" \
    put name yinshixiong
ETCDCTL_API=3 /usr/local/bin/etcdctl \
    --endpoints=https://172.17.174.40:2379,https://172.17.174.41:2379,https://172.17.174.42:2379,https//172.17.174.43:2379,https://172.17.174.44:2379 \
    --cacert="/etc/ssl/etcd/ssl/ca.crt" \
    --cert="/etc/ssl/etcd/ssl/clientNoHost.crt" \
    --key="/etc/ssl/etcd/ssl/clientNoHost-key.crt" \
    get name
echo "工作正常"
