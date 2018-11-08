https://github.com/zhuchuangang/k8s-install-scripts

https://blog.csdn.net/zhuchuangang/article/details/78720538
redis-sentinel集群(k8s脚本)
#环境变量
yum install git -y
cat <<EOF >>/root/.bashrc
alias cdi='cd /root/k8s/install/cluster'
alias gc=' git clone https://github.com/eyii/k8s.git'
alias rk8s='rm -rf /root/k8s'

EOF
source  /root/.bashrc
# 2 安装etcd
#2.1
ipa=192.168.33.
cluster="n11=http://${ipa}11:2380,n12=http://${ipa}12:2380,n13=http://${ipa}13:2380"
sh etcd.sh "n11" "${ipa}11" ${cluster}
sh etcd.sh "n12" "${ipa}12" ${cluster}
sh etcd.sh "n13" "${ipa}13" ${cluster}

第1个参数是etcd当前节点名称ETCD_NAME
第2个参数是etcd当前节点IP地址ETCD_LISTEN_IP
第3个参数是etcd集群地址ETCD_INITIAL_CLUSTER


#2.2验证etcd
etcdctl member list
etcdctl cluster-health


#3 装kubernetes master
#3.1
cd /root/k8s/install/cluster/master
sh kube-master.sh "${ipa}11" "kn11" "http://${ipa}11:2379,http://${ipa}12:2379,http://${ipa}13:2379"
#3.2验证
kubectl get componentstatuses



#4 装kubernetes node
#4.1
cd /root/k8s/install/cluster/node
sh kube-node.sh "${ipa}12" "${ipa}11" "root" "vagrant" "http://${ipa}11:2379,http://${ipa}12:2379,http://${ipa}13:2379"

sh kube-node.sh "${ipa}13" "${ipa}11" "root" "vagrant" "http://${ipa}11:2379,http://${ipa}12:2379,http://${ipa}13:2379"

#4.2 验证
kubectl get nodes





