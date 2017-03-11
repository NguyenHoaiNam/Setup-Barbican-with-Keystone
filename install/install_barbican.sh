#!/bin/bash
## Install Barbican


##########################################
dir_path=$(dirname $0)
path_barbican=/etc/barbican/barbican.conf
log_barbican=/var/log/barbican/

source $dir_path/lib/config.cfg
source $dir_path/lib/functions.sh
source /root/admin-openrc

echocolor "Start to install Barbican"
sleep 3


# Config service
openstack user create barbican --domain default --password  $BARBICAN_PASSWORD
openstack role add --project service --user barbican admin
openstack role create creator
openstack role add --project service --user barbican creator
openstack service create --name barbican --description "Key Manager" key-manager
openstack endpoint create --region RegionOne key-manager public http://$IP:9311
openstack endpoint create --region RegionOne key-manager internal http://$IP:9311
openstack endpoint create --region RegionOne key-manager admin http://$IP:9311


# Create a database:
cat << EOF | mysql -uroot -p$DATABASE_PASSWORD
CREATE DATABASE barbican;
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY '$BARBICAN_PASSWORD';
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY '$BARBICAN_PASSWORD';
FLUSH PRIVILEGES;
EOF


# Install package barbican-service
apt-get -y install barbican-api barbican-keystone-listener barbican-worker

# Edit file barbican.conf
test -f $path_barbican.orig || cp $path_barbican $path_barbican.orig
ops_edit $path_barbican DEFAULT sql_connection mysql+pymysql://barbican:$BARBICAN_PASSWORD@127.0.0.1/barbican?charset=utf8
ops_edit $path_barbican oslo_messaging_rabbit rabbit_userid $RABBIT_USER
ops_edit $path_barbican oslo_messaging_rabbit rabbit_password $RABBIT_PASSWORD/
ops_edit $path_barbican queue enable True
sed -i 's/\/v1: barbican_api/\/v1: barbican-api-keystone/g' /etc/barbican/barbican-api-paste.ini

cat << EOF >> $path_barbican
[keystone_authtoken]

auth_uri = http://$IP:5000
auth_url = http://$IP:35357
memcached_servers = $IP:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = barbican
password = $BARBICAN_PASSWORD
EOF
# Upgrade Database
barbican-manage db upgrade

# Restart service
/etc/init.d/apache2 restart
/etc/init.d/barbican-keystone-listener restart
/etc/init.d/barbican-worker restart

echocolor "Finish installing"