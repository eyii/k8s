#!/bin/bash

#第1个参数是etcd当前节点名称ETCD_NAME
#第2个参数是etcd当前节点IP地址ETCD_LISTEN_IP
#第3个参数是etcd集群地址ETCD_INITIAL_CLUSTER
#例子：
#sh etcd.sh "node01" "172.16.120.151" "node01=http://172.16.120.151:2380,node02=http://172.16.120.152:2380,node03=http://172.16.120.153:2380"
#sh etcd.sh "node02" "172.16.120.152" "node01=http://172.16.120.151:2380,node02=http://172.16.120.152:2380,node03=http://172.16.120.153:2380"
#sh etcd.sh "node03" "172.16.120.153" "node01=http://172.16.120.151:2380,node02=http://172.16.120.152:2380,node03=http://172.16.120.153:2380"

if [ $(getenforce) = "Enabled" ]; then
setenforce 0
fi
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config


ETCD_VERSION=v3.2.4

ETCD_FILE=etcd-$ETCD_VERSION-linux-amd64
etd_file_url=https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/$ETCD_FILE.tar.gz
echo $etd_file_url
if [ ! -f "./$ETCD_FILE.tar.gz" ]; then
  wget https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/$ETCD_FILE.tar.gz
fi

if [ ! -f "./$ETCD_FILE.tar.gz" ]; then
 echo './$ETCD_FILE.tar.gz 文件下载失败'
fi

tar xzvf $ETCD_FILE.tar.gz
echo '解压 完'
ETCD_BIN_DIR=/opt/kubernetes/bin
ETCD_CFG_DIR=/opt/kubernetes/cfg
mkdir -p $ETCD_BIN_DIR
mkdir -p $ETCD_CFG_DIR

cp $ETCD_FILE/etcd $ETCD_BIN_DIR
cp $ETCD_FILE/etcdctl $ETCD_BIN_DIR
rm -rf $ETCD_FILE
echo 'bash_profile 完'
sed -i 's/$PATH:/$PATH:\/opt\/kubernetes\/bin:/g' ~/.bash_profile
source ~/.bash_profile
#exec bash --login

ETCD_DATA_DIR=/var/lib/etcd
mkdir -p ${ETCD_DATA_DIR}
echo 'mkdir ${ETCD_DATA_DIR}'

ETCD_NAME=${1:-"default"}
ETCD_LISTEN_IP=${2:-"0.0.0.0"}
ETCD_INITIAL_CLUSTER=${3:-}


cat <<EOF >/opt/kubernetes/cfg/etcd.conf
# [member]
ETCD_NAME="${ETCD_NAME}"
ETCD_DATA_DIR="${ETCD_DATA_DIR}/default.etcd"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${ETCD_LISTEN_IP}:2380"
ETCD_INITIAL_CLUSTER="${ETCD_INITIAL_CLUSTER}"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://${ETCD_LISTEN_IP}:2379"
#[proxy]
#[security]
EOF


cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
[Service]
Type=simple
WorkingDirectory=${ETCD_DATA_DIR}
EnvironmentFile=-/opt/kubernetes/cfg/etcd.conf
ExecStart=/bin/bash -c "GOMAXPROCS=\$(nproc) /opt/kubernetes/bin/etcd"
Type=notify
[Install]
WantedBy=multi-user.target
EOF
echo '启动服务中'
systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd

