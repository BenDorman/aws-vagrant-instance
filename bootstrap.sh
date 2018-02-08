#! /bin/bash

yum makecache fast
yum -y update
yum -y groupinstall "Server with GUI"
yum -y install git


cat <<EOF > /etc/yum.repos.d/xrdp.repo
[xrdp]
name=xrdp
baseurl=http://li.nux.ro/download/nux/dextop/el7/x86_64/
enabled=1
gpgcheck=0
EOF

yum –y install tigervnc-server
yum -y install xrdp
systemctl enable xrdp.service


chcon --type=bin_t /usr/sbin/xrdp
chcon --type=bin_t /usr/sbin/xrdp-sesman

systemctl start xrdp.service

#shut down default firewall setup - redundant for AWS with Security Groups
systemctl stop firewalld

# this is redundant also for AWS
# systemctl enable ntpd
# systemctl start ntpd


useradd -m tibco
chpasswd <<EOF
tibco:tibco123
EOF

# Required for python-pip
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install epel-release-latest-7.noarch.rpm



#AWS CLI - python install program pip required

#make PIP available
yum -y install python-pip
pip install --upgrade pip


#Docker install community Edition. Not supported on redhat linux ... but one could also start with Ubuntu [etc]

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
yum-config-manager --enable docker-ce-test
yum makecache fast
yum -y install --setopt=obsoletes=0 docker-ce-17.03.2.ce-1.el7.centos.x86_64 docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch
systemctl enable docker
systemctl start docker
systemctl status docker
#verify
docker run hello-world

# The rest of this has to be available to the non-root user.
#Also the non-root user should be a sudoer

cp /etc/sudoers{,.hold}
sed -e '/^root/a\
tibco    ALL=(ALL)    ALL' /etc/sudoers.hold > /etc/sudoers
rm /etc/sudoers.hold

cd /usr/local/bin

#Kops

wget https://github.com/kubernetes/kops/releases/download/1.7.0/kops-linux-amd64
chmod +x kops-linux-amd64 && mv kops-linux-amd64 kops

#Kubernetes 

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl

# Enable user commands [especially AWS CLI] for TIBCO account

su - tibco <<EOF1

# AWS CLI
pip install awscli --upgrade --user

#kubectl command completion
source <(kubectl completion bash)

#kube-aws
if [ ! -f kube-aws ]; then 
	git clone https://github.com/kubernetes-incubator/kube-aws.git
fi
EOF1
