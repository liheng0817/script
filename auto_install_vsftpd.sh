#!/bin/bash
# auth:fengdeyingzi
# func:vsftpd安装

. /etc/init.d/functions
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#ip=`curl -s  http://ifconfig.me/`
ip=`curl -s  http://members.3322.org/dyndns/getip`

#查看系统版本#
sys=`rpm -q centos-release|cut -d- -f3`
echo -e "\033[32m Your system version is ${sys}.x\033[0m"

create_ftpuser () {
echo -e "\033[32m 创建FTP系统用户 \033[0m"
read -p "Please input FTP user:" FTPUSER
read -p "Please input FTP user password:" PASS
#B=`cat /etc/passwd|grep $FTPUSER |awk  -F: '{print $1 't' $7}'|awk -F / '{print $1":"$2$3}'`
id $FTPUSER
if [ $? -eq 0 ];then
       echo -e "\033[32m $FTPUSER User already exists \033[0m"
   else
       useradd -m -d /home/$FTPUSER -s /sbin/nologin $FTPUSER >/dev/null
       echo  $PASS | passwd --stdin $FTPUSER >/dev/null
       echo -e "\033[32m $FTPUSER User has been created successfully \033[0m"
fi	
}

init_vsftpd () {
confdir=/etc/vsftpd
rpm -q vsftpd >/dev/null
if [ $? -eq 0 ];then
   echo -e "\033[31m Vsftpd has been installed \033[0m" && exit
   else
       yum install -y vsftpd >/dev/null
       [ $? -eq 0 ]&& action "Vsftpd server Successfully installed" /bin/true
fi
cd $confdir
cat >vsftpd.conf <<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=NO
xferlog_std_format=YES
listen=YES
listen_ipv6=NO
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
pasv_enable=YES
pasv_min_port=2000
pasv_max_port=2050
EOF
}

test () {
echo -e "\033[5;32;49;1m ########################################## \033[25;39;49;0m"
echo -e "\033[5;32;49;1m #       Auto Install Vsftpd.service     ## \033[25;39;49;0m"
echo -e "\033[5;32;49;1m #       Press Ctrl + C to cancel        ## \033[25;39;49;0m"
echo -e "\033[5;32;49;1m #       Press Any key to continue       ## \033[25;39;49;0m"
echo -e "\033[5;32;49;1m ########################################## \033[25;39;49;0m"
read -n 1
echo -e "\033[32m 正在安装配置vsftpd.service... \033[0m"
}

install_vsftpd () {
echo -e "\033[32m 准备安装配置vsftpd.service... \033[0m"
if [ $sys -eq 6 ];
   then
	test
	init_vsftpd
	/etc/init.d/vsftpd start
elif [ $sys -eq 7 ];
   then
	test
	init_vsftpd
	systemctl start vsftpd
else	
	exit 1
fi
}

main () {
install_vsftpd
create_ftpuser
}

main

echo -e "\033[36m Vsftpd is Install Successed,server-ip:$ip ftpuser:$FTPUSER Password:$PASS \033[0m"
echo -e "\033[36m 如您开启了系统防火墙或者安全组，请关闭系统防火墙或者配置系统防火墙21及2000到2050端口的放行规则，并在安全组中设置21端口及2000到2050端口放行规则 \033[0m"
