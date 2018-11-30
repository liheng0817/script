#!/bin/bash
#DATE:2018-11-30
#Desc:Auto install Xrdp
#Auth:liheng@anchent.com

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#sys=`rpm -q centos-release|cut -d- -f3`
SOFT=Xrdp
INSTALL_LOG=/opt/install.log
EPEL=/etc/yum.repos.d/epel.repo

echo "###################################################"
echo "#   The script will install Xrdp for centos6/7    #"
echo "#           Press Ctrl + C to cancel              #"
echo "#           Press Any key to continue             #"
echo "###################################################"
read -p "Please input your os version[6 or 7]:" VER
clear

echo -e "\033[32m Your os version is centos$VER \033[0m"
echo -e "\033[5m Press any key to start install $SOFT \033[0m"
read -n 1

centos_6 () {
#######安装xrdp、tigervnc-server#####
if [ ! -f $EPEL ];then
   rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm &&
   install_6
   else
      install_6
fi
	
###########安装图形界面###################
yum -y groupinstall "Desktop" "X Window System" "Chinese Support"
if [ $? -eq 0 ];
   then
      sed -i "s/id:3:initdefault:/id:5:initdefault:/" /etc/inittab
      echo "图形化桌面安装成功" |tee -a $INSTALL_LOG 
#      reboot
else
   echo "图形化桌面安装失败" | tee -a $INSTALL_LOG
fi
clear
}


centos_7 () {
if [ ! -f $EPEL ];then
   rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
   install_7
   else
      install_7
fi
clear
#      reboot
}

install_6 () {
      yum -y install xrdp tigervnc-server
      service xrdp start && chkconfig xrdp on
      if [ $? -eq 0];
         then
            echo "$SOFT install success" |tee -a $INSTALL_LOG
      else
         echo "$SOFT install fail" |tee -a $INSTALL_LOG
      fi
}

install_7 () {
      yum -y groupinstall "GNOME Desktop" "Graphical Administration Tools" &&
      ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target || echo "图形化桌面按照失败" | tee -a $INSTALL_LOG
      wget https://kojipkgs.fedoraproject.org//packages/xorgxrdp/0.2.8/1.el7/x86_64/xorgxrdp-0.2.8-1.el7.x86_64.rpm &&
      rpm -ivh xorgxrdp-0.2.8-1.el7.x86_64.rpm || echo "xorgxrdp 下载失败" | tee -a $INSTALL_LOG &&
      yum -y install xrdp tigervnc-server &&
      systemctl start xrdp || echo "$SOFT 安装失败" |tee -a $INSTALL_LOG &&
      chkconfig xrdp on
}
reboot_sys () {
read -p "${SOFT}已成功安装并启动,需要重启服务器生效,请确认[Y|y|N|n]:" Confirm
case $Confirm in
Y|y)
   reboot
   ;;
N|n)
   echo -e "\033[32m 请稍后重启服务器后，使用远程连接桌面连接测试 \033[0m"
   exit 0
   ;;
*)
   echo INPUT ERROR...
   ;;
esac
}

main () {
case $VER in
6)
   centos_6
   echo -e "\033[32m 安装日志请查看$INSTALL_LOG \033[0m"
   reboot_sys
   ;;
7)
   centos_7
   echo -e "\033[32m 安装日志请查看$INSTALL_LOG \033[0m"
   reboot_sys
   ;;
*)
   echo "Bye bye..."
   exit 1
   ;;
esac
}

main
