#！/bin/bash
#Description:Check UDP Port Shell
#####文件分割####
DATE=`date +"%Y-%m-%d-%H-%M-%S"`
PortNum=xxx
bigfile="ip.txt"
split -l 5 $bigfile text

for iplist in $(ls ./text*)
   do
      cat $iplist | while read ip
         do
            #nmap -sU $ip -p 161 -Pn|awk 'NR==3 {print $5} NR==6 {print $1,$2}' | tee -a file.txt
            a=`nmap -sU $ip -p $PortNum -Pn|awk 'NR==6 {print $2}'`
            b="open"
			if [ "$a" == "$b" ];then
                echo "$ip":$PortNum udp端口open，请关闭  >> check.log
                   else
                      echo "$ip 正常"
            fi

done
done
rm -fr text*

#微信告警#
if [[ -f check.log ]];then
    CropID='wxaa7b9ec92d92b178'
    Secret='CDmarS3vpgh51clhd-Lny13cOFic5sXu8iQbie1faZU'
    GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
    Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $10}')
    PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
    file=`cat check.log`

    c=`echo "{
        \"touser\" : \"@all\",
        \"msgtype\" : \"text\",   
        \"agentid\" : \"1000002\",
        \"text\" : {           
            \"content\" : \"$file\"}   
      }"`

    /usr/bin/curl --data-ascii "$c" $PURL
    rm -rf check.log
else
    echo "$DATE 检测正常" >> normal.log
fi
