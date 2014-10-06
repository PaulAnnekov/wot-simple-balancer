#!/bin/bash

ANSIBLE_DIR=$1
ANSIBLE_PLAYBOOK=$2
ANSIBLE_HOSTS=$3
TEMP_HOSTS="/tmp/ansible_hosts"
BACKPORTS_LIST="/etc/apt/sources.list.d/debian-wheezy-backports.list"

if [ ! -f /vagrant/$ANSIBLE_PLAYBOOK ]; then
	echo "Cannot find Ansible playbook"
	exit 1
fi

if [ ! -f /vagrant/$ANSIBLE_HOSTS ]; then
	echo "Cannot find Ansible hosts"
	exit 2
fi

if [ ! -f $BACKPORTS_LIST ]; then
	echo "Installing Ansible"	
	echo "deb http://http.debian.net/debian wheezy-backports main" >> ${BACKPORTS_LIST}
	apt-get update
	apt-get install ansible -y
fi

cp /vagrant/${ANSIBLE_HOSTS} ${TEMP_HOSTS} && chmod -x ${TEMP_HOSTS}

echo "Running Ansible"
# Disable python output bufferization to display ansible log as it outputs.
PYTHONUNBUFFERED="YOUR_SET" ansible-playbook /vagrant/${ANSIBLE_PLAYBOOK} --inventory-file=${TEMP_HOSTS} --connection=local

rm ${TEMP_HOSTS}
