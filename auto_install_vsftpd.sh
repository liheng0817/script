#!/bin/bash
# auth:fengdeyingzi
# func:vsftpd安装

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
confdir=/etc/vsftpd
#ip=`curl -s  http://ifconfig.me/`
#ip=`curl -s "ifconfig.me"`
ip=`curl -s  http://members.3322.org/dyndns/getip`

#查看系统版本#
sys=`rpm -q centos-release|cut -d- -f3`
echo "Your system version is ${sys}.x"
echo "创建FTP用户"
read -p "Please input FTP user:" FTPUSER
read -p "Please input FTP user password:" PASS
useradd -m -d /home/$FTPUSER -s /sbin/nologin $FTPUSER
echo $PASS | passwd --stdin $FTPUSER

#安装vsftpd函数
install_vsftpd () {
yum install -y vsftpd
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
#安装配置vsftpd#
echo "安装配置vsftpd"
if [ $sys -eq 6 ];
   then
	install_vsftpd
	/etc/init.d/vsftpd start
elif [ $sys -eq 7 ];
   then
	install_vsftpd
	systemctl start vsftpd
else	
	exit 1
fi

echo -e "\033[42;37m Vsftpd is Install Successed,server-ip:$ip ftpuser:$FTPUSER Password:$PASS \033[0m"
echo -e "\033[42;37m 如您开启了系统防火墙或者安全组，请关闭系统防火墙或者配置系统防火墙21及2000到2050端口的放行规则，并在安全组中设置21端口及2000到2050端口放行规则 \033[0m"
