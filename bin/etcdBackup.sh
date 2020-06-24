#!/usr/bin/env bash
# 恢复etcd数据
ETCDCTL_API=3 etcdctl --cacert="/etc/ssl/etcd/ssl/ca.crt" --cert="/etc/ssl/etcd/ssl/etcd.crt" --key="/etc/ssl/etcd/ssl/etcd.key" --endpoints="https://127.0.0.1:2379" --data-dir=/var/lib/etcd/ snapshot restore /data/backup_etcd/2020-06-15-17-53-08.etcd.db
