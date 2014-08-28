#!/bin/bash -ve

#update me if new google compute image packages release
export COMPUTE_VERSION=1.1.6

export DEBIAN_FRONTEND=noninteractive

# make sure we have all ubuntu repositories
sudo cp /vagrant/conf/apt.sources.list /etc/apt/sources.list

## install ubuntu packages
sudo -E apt-get update -q
sudo -E apt-get upgrade -y -q -u
sudo -E apt-get install -y -q kpartx ethtool

cd /vagrant
wget -c https://github.com/GoogleCloudPlatform/compute-image-packages/releases/download/${COMPUTE_VERSION}/python-gcimagebundle_${COMPUTE_VERSION}-1_all.deb
wget -c https://github.com/GoogleCloudPlatform/compute-image-packages/releases/download/${COMPUTE_VERSION}/google-startup-scripts_${COMPUTE_VERSION}-1_all.deb
wget -c https://github.com/GoogleCloudPlatform/compute-image-packages/releases/download/${COMPUTE_VERSION}/google-compute-daemon_${COMPUTE_VERSION}-1_all.deb

sudo dpkg -i *_${COMPUTE_VERSION}-1_all.deb

sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sudo -E apt-get install ntp -y -q
sudo cp /vagrant/conf/ntp.conf /etc/ntp.conf

sudo rm -rf /etc/hostname
sudo cp /vagrant/conf/hosts /etc/hosts
sudo ln -sf /usr/share/google/set-hostname /etc/dhcp/dhclient-exit-hooks.d/

sudo cp /vagrant/conf/ttyS0.conf /etc/init/ttyS0.conf

sudo cp /vagrant/conf/grub /etc/default/grub
sudo update-grub2

sudo su -c "echo "GOOGLE" > /etc/ssh/sshd_not_to_be_run"

# download google cloud SDK
wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
tar zxvf google-cloud-sdk.tar.gz
/vagrant/google-cloud-sdk/install.sh --usage-reporting false --disable-installation-options  --bash-completion true  --path-update true
source ~/.bashrc

# WARNING: after this you can't access the VM anymore
sudo rm -rf /etc/ssh/ssh_host_*

# make the image
sudo gcimagebundle -d /dev/sda -r / -o /vagrant/output --loglevel=DEBUG --log_file=/tmp/image_bundle.log
