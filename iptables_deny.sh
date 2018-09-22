#!/bin/bash
#Description:Detection of SSH violence
#Usage:"nohup /bin/bash ssh_deny.sh &" OR "Set a crontab task"
###########################################################################################################
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

sys=`rpm -q centos-release|cut -d- -f3`
#echo -e "\033[32m Your system version is ${sys}.x\033[0m"
##############################################
centos_6 () {
rpm -q iptables >/dev/null
if [ $? -eq 0 ];
    then
        /etc/init.d/iptables status >/dev/null
        if [ $? -eq 0  ];
            then
                echo 0 >/dev/null
        else
            /etc/init.d/iptables start >/dev/null
        fi
elif [ $? -ne 0 ];
    then
        yum install -y iptables >/dev/null &&
        /etc/init.d/iptables start >/dev/null
fi
}

centos_7 () {
rpm -q iptables-services >/dev/null
if [ $? -eq 0 ];
    then
        systemctl status iptables >/dev/null
        if [ $? -eq 0  ];
            then
                echo 0 >/dev/null
        else
            systemctl start iptables >/dev/null
        fi
elif [ $? -ne 0 ];
    then
        yum install -y iptables-services >/dev/null &&
        systemctl start iptables >/dev/null
fi
}

#########################

tianjia_iptables () {
if [ $sys -eq 6 ];
   then
        centos_6
        iptables -A INPUT -p tcp -s $IP -j DROP
#        /etc/init.d/iptables save
#       /etc/init.d/iptables restart

elif [ $sys -eq 7 ];
   then
        centos_7
        iptables -A INPUT -p tcp -s $IP -j DROP
#        service iptables save >/dev/null
#        systemctl restart iptables >/dev/null
else
        exit 1
        fi
}
#########################

main () {
A=5
cat /var/log/secure|awk '/Failed password/ {print $(NF-3)}'|sort|uniq -c|awk '{print $2"="$1}'> /etc/ssh/block-ip
for i in `cat /etc/ssh/block-ip`
do
    IP=`echo $i |awk -F = '{print $1}'`
    NUM=`echo $i |awk -F = '{print $2}'`
    if [ $NUM -gt $A ];
        then
            iptables -nL | grep $IP >/dev/null
                if [ $? -ne 0 ];
                    then
                        tianjia_iptables
#                        service iptables save >/dev/null
#                        systemctl restart iptables >/dev/null
              fi
        fi
done
}

main
service iptables save >/dev/null
if [ $sys -eq 6 ];
   then
      /etc/init.d/iptables restart
else
   systemctl restart iptables >/dev/null
fi
