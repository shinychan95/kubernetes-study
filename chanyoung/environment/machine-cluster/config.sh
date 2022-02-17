#!/usr/bin/env bash

# vim configuration
echo 'alias vi=vim' >> /etc/profile

# swapoff -a to disable swapping
swapoff -a
# sed to comment the swap partition in /etc/fstab
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

# kubernetes repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# permissive 모드로 SELinux 설정(효과적으로 비활성화)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# 해당 설정은 irteamsu 권한으로 불가능 (개인적으로 문의 바랍니다)
#modprobe br_netfilter

# RHEL/CentOS 7 have reported traffic issues being routed incorrectly due to iptables bypassed
# 리눅스 노드의 iptables가 브리지된 트래픽을 올바르게 보기 위한 요구 사항
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


# local small dns & vagrant cannot parse and delivery shell code.
echo "10.168.200.90 dev-kubernetes-master-ncl" >> /etc/hosts
echo "10.105.197.18 dev-kubernetes-worker001-ncl" >> /etc/hosts
echo "10.168.244.46 dev-kubernetes-worker002-ncl" >> /etc/hosts
echo "10.168.235.76 dev-kubernetes-worker003-ncl" >> /etc/hosts

# config DNS
#cat <<EOF > /etc/resolv.conf
#nameserver 1.1.1.1 #cloudflare DNS
#nameserver 8.8.8.8 #Google DNS
#EOF
