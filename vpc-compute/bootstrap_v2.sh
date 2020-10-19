#!/bin/bash

#set -euo pipefail

lsof /var/lib/dpkg/lock
if [ $? -ne 1 ]; then
        echo "Another process has f-locked /var/lib/dpkg/lock" 1>&2
        exit 1
fi

# IBM Cloud
curl -sL https://ibm.biz/idt-installer | bash
# Mutagen (for dev)
wget https://github.com/mutagen-io/mutagen/releases/download/v0.11.5/cli_linux_amd64_v0.11.5.tar.gz
tar xvfz cli_linux_amd64*
chmod +x mutagen
mv mutagen /usr/local/bin/mutagen
# k9s for ncurses K8s exploration
wget https://github.com/derailed/k9s/releases/download/v0.22.1/k9s_Linux_x86_64.tar.gz
tar xvfz k9s*
chmod +x k9s
mv k9s /usr/local/bin/k9s
# OpenShift CLI because: OCP
wget http://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
tar xvfz ./oc.tar.gz
chmod +x oc
mv oc /usr/local/bin/oc

#tmux
curl https://raw.githubusercontent.com/jpapejr/dotfiles/master/.tmux.conf -o /root/.tmux.conf

# touch done file in /root
touch /root/cloudinit.done