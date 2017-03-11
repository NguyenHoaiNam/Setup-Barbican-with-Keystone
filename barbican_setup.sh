#!/bin/bash
set -e
dir_path=$(dirname $0)
source $dir_path/lib/functions.sh

echocolor "Installing Barbican at Newton release"
sleep 3 

if [ "$1" == "install" ]; then
	source $dir_path/install/install_dependency.sh
	source $dir_path/install/install_keystone.sh
	source $dir_path/install/install_barbican.sh

else
	echocolor "Please input install to your command to start installing Barbicain. Thanks"
fi