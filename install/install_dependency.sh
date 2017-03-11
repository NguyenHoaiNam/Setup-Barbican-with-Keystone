#!/bin/bash
## Install Database

###############################################################################
## Khai bao cac chuong trinh ho tro
dir_path=$(dirname $0)
source $dir_path/lib/config.cfg

apt install -y crudini

# Step 1: Install RabbitMQ
apt-get install -y rabbitmq-server
rabbitmqctl add_user $RABBIT_USER $RABBIT_PASSWORD
rabbitmqctl set_permissions $RABBIT_USER ".*" ".*" ".*"


# Step2: Install Mysql-server
echo mysql-server mysql-server/root_password password $DATABASE_PASSWORD | debconf-set-selections
echo mysql-server mysql-server/root_password_again password $DATABASE_PASSWORD | debconf-set-selections
apt-get -y install mysql-server

# Step 3: Install Openstack client and Barbican
apt -y install python-openstackclient
apt -y install python-barbicanclient

# Step 3: App repo
apt install -y software-properties-common
add-apt-repository -y cloud-archive:newton
apt -y update && apt -y  dist-upgrade