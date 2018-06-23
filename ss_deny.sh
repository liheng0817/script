#!/bin/bash
#Description:Detection of SSH violence
#Usage:"nohup /bin/bash ssh_deny.sh &" OR "Set a crontab task"
###########################################################################################################
A=5
cat /var/log/secure|awk '/Failed password/ {print $(NF-3)}'|sort|uniq -c|awk '{print $2"="$1}'> /tmp/black.txt
for i in `cat /tmp/black.txt`
do
        IP=`echo $i |awk -F = '{print $1}'`
        NUM=`echo $i |awk -F = '{print $2}'`
        if [ $NUM -gt $A ];
        then
        grep $IP /etc/hosts.deny >/dev/null
        if [ $? -gt 0 ];
        then
        echo "sshd:$IP" >>/etc/hosts.deny
        fi
        fi
done
