#!/bin/bash
#Date 2018/6/23
#mail liheng@anchnet.com
IP=`ifconfig |awk -F '[ ]+' 'NR==2 {print $3}'`
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
setenforce 0
time_sync() {
which  ntpdate
if [ $? -eq 0 ];then
	/usr/sbin/ntpdate time1.aliyun.com
	echo "*/5 * * * * /usr/sbin/ntpdate -s time1.aliyun.com">>/var/spool/cron/root	
else
	yum install ntpdate -y
	/usr/sbin/ntpdate time1.aliyun.com
	echo "*/5 * * * * /usr/sbin/ntpdate -s time1.aliyun.com">>/var/spool/cron/root	
fi
}
clear
echo "##########################################"
echo "#       Auto Install zabbix.            ##"
echo "#       Press Ctrl + C to cancel        ##"
echo "#       Press Any key to continue       ##"
echo "##########################################"
echo "(1) Install zabbix3.0"
echo "(2) Install zabbix3.2"
echo "(3) Install zabbix3.4"
echo "(4) Install zabbix4.0"
echo "(5) EXIT"
read -p "Please input your choice:" OPTION
case $OPTION in
1)
  URL=http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
  VER=zbx-3.0
;;
2)
  URL=http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
  VER=zbx-3.2
;;
3)
  URL=http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
  VER=zbx-3.4
;;
4)
  URL=http://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
  VER=zbx-4.0
;;
5)
  echo -e "\033[41;37m You choice cannel! \033[0m" && exit 0
;;
*)
  echo -e "\033[41;37m Input Error! Place input{1|2|3|4} \033[0m" && exit 1
;;
esac
clear
echo -e "\033[32m You choice install $VER.Install\033[0m"
echo -e "\033[5m Press any key to start install $VER... \033[0m"
read -n 1
rpm -ivh $URL
yum makecache
clear
config_iptables() {
systemctl status firewalld
if [ $? -eq "0" ];
   then
   firewall-cmd --zone=public --add-port=80/tcp --permanent
   firewall-cmd --zone=public --add-port=10051/tcp --permanent
   firewall-cmd --zone=public --add-port=10050/tcp --permanent
   firewall-cmd --reload
   else
   echo -e "\033[32m firewalld is stopd\033[0m"
fi
}
install_mariadb() {
yum install mariadb mariadb-server net-tools -y
systemctl start mariadb
mysqladmin -uroot password westos
mysql -uroot -pwestos -e "create database zabbix default character set utf8 collate utf8_bin;"
mysql -uroot -pwestos -e "grant all on zabbix.* to 'zabbix'@'localhost' identified by 'zabbix';"
}
install_zabbix() {
yum install zabbix-server-mysql zabbix-agent zabbix-web-mysql zabbix-get mailx autoconf dos2unix vim zcat libxml* net-snmp-devel curl-devel unixODBC-devel OpenIPMI-devel java-devel -y
}
import_data() {
cd /usr/share/doc/zabbix-server*
zcat create.sql.gz |mysql -uroot -pwestos zabbix
}
config_file() {
sed -i "s/# DBHost=localhost/DBHost=localhost/g" /etc/zabbix/zabbix_server.conf
sed -i "s/# DBPassword=/DBPassword=zabbix/g" /etc/zabbix/zabbix_server.conf
sed -i "s:`grep date.timezone /etc/httpd/conf.d/zabbix.conf`:php_value date.timezone Asia\/Shanghai:g" /etc/httpd/conf.d/zabbix.conf
}
start() {
systemctl start mariadb httpd zabbix-server zabbix-agent
}
main() {
time_sync
install_mariadb
install_zabbix
import_data
config_file
config_iptables
start
}
main
echo -e "\033[42;37m $VER is Install Successed,Username:Admin Password:zabbix \033[0m"
echo -e "\033[42;37m rul:http://$IP/zabbix \033[0m"
echo -e "\033[42;37m MySql:Username:root Password:westos Username:zabbix Password:zabbix \033[0m"
