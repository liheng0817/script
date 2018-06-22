#!/bin/bash
#Date 2018-02-11
#Description:centos7.x自动化安装shadowsocks

#####关闭防火墙#####
systemctl stop firewalld.service
systemctl disable firewalld.service

#####关闭selinux####
setenforce 0

#####添加epel源
rpm -Uvh http://mirrors.yun-idc.com/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
yum makecache

####服务搭建####
KEY="bluefly"
Encryption="aes-256-cfb"
IP=`ifconfig|awk -F '[ ]+' 'NR==2 {print $3}'`
yum install python-pip net-tools -y
pip install --upgrade pip
pip install shadowsocks

####启动服务####
echo "ssserver -p 9999 -k bluefly -m aes-256-cfb -t 300 --fast-open --workers 5 &">> /etc/rc.local
chmod +x /etc/rc.d/rc.local
ssserver -p 9999 -k bluefly -m aes-256-cfb -t 300 --fast-open --workers 5 &
echo -e "\033[42;37m serverip:$IP passwd:$KEY encryption:$Encryption \033[0m"
