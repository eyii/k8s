https://github.com/zhuchuangang/k8s-install-scripts

https://blog.csdn.net/zhuchuangang/article/details/78720538
redis-sentinel集群(k8s脚本)

ipa=192.168.33.
cluster="n11=http://${ipa}.11:2380,n12=http://${ipa}.12:2380,n13=http://${ipa}.13:2380"
sh etcd.sh "node01" "${ipa}.11" ${cluster}
sh etcd.sh "node02" "${ipa}.12" ${cluster}
sh etcd.sh "node03" "${ipa}.13" ${cluster}

第1个参数是etcd当前节点名称ETCD_NAME
第2个参数是etcd当前节点IP地址ETCD_LISTEN_IP
第3个参数是etcd集群地址ETCD_INITIAL_CLUSTER