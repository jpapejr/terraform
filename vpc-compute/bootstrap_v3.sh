#!/bin/bash

#set -euo pipefail

lsof /var/lib/dpkg/lock
if [ $? -ne 1 ]; then
        echo "Another process has f-locked /var/lib/dpkg/lock" 1>&2
        exit 1
fi

# Install Docker
dpkg --configure -a
apt update
apt install docker.io nfs-common uuid -y
# Create `coder` user
useradd coder --shell /bin/bash -G docker
# Set `coder`'s password
PW=`uuid -v1`
echo "coder:$PW" | chpasswd
# ensure `coder`'s home exists
mkdir -p /home/coder/projects
echo $PW > /home/coder/pw.txt
mount /dev/vdb /home/coder/projects
chown coder:coder /home/coder
echo "coder   ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
# install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
install ./minikube /usr/local/bin/minikube

#tmux
curl https://raw.githubusercontent.com/jpapejr/dotfiles/master/.tmux.conf -o /root/.tmux.conf

# touch done file in /root
touch /root/cloudinit.done