#!/bin/bash -ex

# This function is to show to the screen
function echocolor {
    echo "$(tput setaf 3)##### $1 #####$(tput sgr0)"
}

# This function is to edit the config file in Openstack
function ops_edit {
    crudini --set $1 $2 $3 $4
}