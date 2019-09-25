#!/bin/bash
value=$( grep -ic "entry" /etc/hosts )
if [ $value -eq 0 ]
then
echo "
################ ceph-cookbook host entry ############

192.168.1.104 ceph-node4
192.168.1.105 ceph-node5
192.168.1.106 ceph-node6


######################################################
" >> /etc/hosts
fi
if [ -e /etc/redhat-release ]
then
    
	setenforce 0  #disable SELinux
	
	systemctl disable NetworkManager
    systemctl restart network
	
	#修改ssh 允许密码登录
    sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    sudo service sshd restart
	
	# Enable ports that are required by CEPH on the Linux firewall
	# Each monitor:
    # 6789/tcp
    # Each manager, osd node:
    # from 6800/tcp to 7300/tcp
    # Each metadata server:
    # 6800/tcp
    # Each object gateway:
    # defaults to port 7480/tcp, but you can easily change it to 80 and 443 (if you want SSL).
	firewall-cmd --zone=public --add-port=6789/tcp --permanent
	firewall-cmd --zone=public --add-port=7480/tcp --permanent
	firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent
	firewall-cmd --reload
	firewall-cmd --zone=public --list-all
	
	# 关掉防火墙可能更靠谱
	systemctl disable firewalld.service
    systemctl stop firewalld.service
		
	yum update -y
		
	#Install and configure NTP on all VMs:
	yum install ntp ntpdate -y 
	ntpdate pool.ntp.org 
	systemctl restart ntpdate.service
	systemctl restart ntpd.service      
	systemctl enable ntpd.service      
	systemctl enable ntpdate.service

 
	if [ -e /etc/rc.d/init.d/ceph ]
	then
	service ceph restart mon > /dev/null 2> /dev/null
	fi
	
	
	#disable SELinux
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

fi
