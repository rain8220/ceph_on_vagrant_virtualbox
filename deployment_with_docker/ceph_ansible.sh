#!/bin/bash



cd ~   #root by default
yum install git -y
yum install sshpass -y

ssh-keygen -t dsa -f ~/.ssh/id_dsa -N ""

#set password free access from ansible master node to the other nodes
sshpass -v -p vagrant ssh-copy-id -o StrictHostKeyChecking=no root@ceph-node4
sshpass -v -p vagrant ssh-copy-id -o StrictHostKeyChecking=no root@ceph-node5
sshpass -v -p vagrant ssh-copy-id -o StrictHostKeyChecking=no root@ceph-node6

git clone https://github.com/ceph/ceph-ansible.git

ln -s ./ceph-ansible/group_vars /etc/ansible/group_vars

cd ceph-ansible/
git checkout stable-3.2  #mimic stable version

#install pip
sudo yum -y install epel-release
sudo yum -y install python-pip
sudo pip install --upgrade pip

#use pip and the provided requirements.txt to install Ansible and other needed Python libraries:
sudo pip install -r requirements.txt


if [ ! -d "/etc/ansible" ]; then
  mkdir /etc/ansible
fi

echo "
[mons]
ceph-node4
ceph-node5
ceph-node6

[osds]
ceph-node4
ceph-node5
ceph-node6

[clients]
ceph-node4
ceph-node5
ceph-node6

[mgrs]
ceph-node4
" >> /etc/ansible/hosts

cd ~/ceph-ansible
cp site-docker.yml.sample site-docker.yml

cd ~/ceph-ansible/group_vars
cp all.yml.sample all.yml

echo "
mon_group_name: mons
osd_group_name: osds
client_group_name: clients
mgr_group_name: mgrs
centos_package_dependencies:
  - python-pycurl
  - epel-release
  - python-setuptools
  - libselinux-python
ntp_service_enabled: true
ntp_daemon_type: chronyd
upgrade_ceph_packages: False
ceph_origin: repository
ceph_repository: community
ceph_mirror: http://download.ceph.com
ceph_stable_key: https://download.ceph.com/keys/release.asc
ceph_stable_release: mimic
ceph_stable_repo: '{{ ceph_mirror }}/debian-{{ ceph_stable_release }}\'
ceph_stable_redhat_distro: el7
generate_fsid: true
ceph_conf_key_directory: /etc/ceph
ceph_keyring_permissions: '0600'
cephx: true
monitor_interface: eth2
ip_version: ipv4
journal_size: 5120
block_db_size: -1 
public_network: 192.168.56.0/24
cluster_network: 192.168.1.0/24
osd_mkfs_type: xfs
osd_mkfs_options_xfs: -f -i size=2048
osd_mount_options_xfs: noatime,largeio,inode64,swalloc
osd_objectstore: bluestore
ceph_docker_image: "ceph/daemon"
ceph_docker_image_tag: latest-mimic-devel
ceph_docker_registry: docker.io
containerized_deployment: true
" >>all.yml

cp osds.yml.sample osds.yml
echo "
devices:                                                                                                   
  - /dev/sdb
  - /dev/sdc
  - /dev/sdd
osd_scenario: lvm 
" >>osds.yml

cp clients.yml.sample clients.yml
cp mons.yml.sample mons.yml

cd ~/ceph-ansible
ansible-playbook site-docker.yml                                                                                     