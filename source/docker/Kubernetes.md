# Kubernetes

## 1 安装

```shell
# 支持https传送
apt update && apt install -y apt-transport-https
# 添加访问公钥
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
# 添加源
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
# 更新缓存索引
apt update
# 查看kubectl可用版本
apt-cache madison kubectl
# 安装指定版本
apt install -y kubectl=1.18.9-00 kubelet=1.18.9-00 kubeadm=1.18.9-00
# 安装最新版本
apt install  kubectl kubelet kubeadm -y
# 开机自启动
systemctl enable kubelet
```

