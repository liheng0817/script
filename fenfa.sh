#!/bin/sh
DATE=`date +"%Y-%m-%d-%H-%M-%S"`
list_file="/tmp/iplist.txt"
config_file="/usr/local/smokeping/etc/config"

cat $list_file | while read host_ip password
do
#   echo "$host_ip"
   ping -c 1 $host_ip > /dev/null
   if
	[[ $? -eq 0 ]];
   then
	sshpass -p $password scp -o stricthostkeychecking=no "$config_file" root@"$host_ip":"$config_file" > /dev/null
	sshpass -p $password ssh -n  -o stricthostkeychecking=no  root@"$host_ip" '/etc/init.d/smokeping restart' > /dev/null
	echo "主机:$host_ip 同步重启完成" >> /tmp/goodip.txt
   else
	
	echo "主机:$host_ip 不通" |tee -a /tmp/badip.txt
   fi
done 
if
	[[ -f /tmp/badip.txt ]];
   then
	CropID='wxaa7b9ec92d92b178'
	Secret='4mH6rkWCHKpqkcB2ZqvsK-4eMyFrGVVf2iba_9kUDH0'
	GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
	Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $10}')
	PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
	file1=`cat /tmp/badip.txt`

    a=`echo "{
        \"touser\" : \"@all\",
        \"msgtype\" : \"text\",   
        \"agentid\" : \"1000004\",
        \"text\" : {           
        \"content\" : \"$file1\"}   
             }"`
    /usr/bin/curl --data-ascii "$a" $PURL
	rm -fr /tmp/badip.txt
fi   
   if
	[[ -f /tmp/goodip.txt ]];
   then
	CropID='wxaa7b9ec92d92b178'
        Secret='4mH6rkWCHKpqkcB2ZqvsK-4eMyFrGVVf2iba_9kUDH0'
        GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
        Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $10}')
        PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
        file2=`cat /tmp/goodip.txt`

    b=`echo "{
        \"touser\" : \"@all\",
        \"msgtype\" : \"text\",   
        \"agentid\" : \"1000004\",
        \"text\" : {           
        \"content\" : \"$file2\"}   
             }"`

    /usr/bin/curl --data-ascii "$b" $PURL
	rm -fr /tmp/goodip.txt	
fi
