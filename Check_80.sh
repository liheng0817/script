#!/bin/bash
DATE=`date +"%Y%m%d_%H%M%S"`
a=`cat whitelist.txt`
if [[ -f iplist.txt ]];then
cat iplist.txt | grep -v "$a" > ip.txt
else
exit 1
fi

SplitFile()
{
linenum=`wc -l $1 |awk '{print $1}'`
if [[ $linenum -le $2 ]]
then
echo "The lines of this file is less then $2, Are you kidding me..."
exit
fi
Split=`expr $linenum / $2`
Num1=1
FileNum=1
test -d SplitFile || mkdir -p SplitFile
while [ $Num1 -lt $linenum ]
do
Num2=`expr $Num1 + $Split`
sed -n "${Num1}, ${Num2}p " $1 > SplitFile/$1-$FileNum
Num1=`expr $Num2 + 1`
FileNum=`expr $FileNum + 1`
done
}
SPLIT_NUM=${1:-50}
FILE=${2:-ip.txt}
if [[ -f ip.txt ]]; then
	SplitFile $FILE $SPLIT_NUM
else
	echo "$DATE Not Found ip.txt" >> check80.log
	exit 1
fi


for iplist in $(ls ./SplitFile/*)
	do
		cat $iplist | while read ip
			do
			tweb=`curl -I -m 10 -o /dev/null -s -w %{http_code} http://$ip:80`
			            if [[ $testweb == 200 ]];then
			                    echo " $ip 80 可以访问，请检查后关闭 " >> 80.txt
			            elif [[ $testweb == 301 ]];then
			                    echo " $ip 80 301重定向，请检查后关闭 " >> 80.txt
			            else
			                    echo  “$ip 正常”                       
			            fi
			done &
done
wait
rm -rf SplitFile
rm -rf ip.txt

#微信告警
if [[ -f 80.txt ]]; then
    CropID='wxda4519cae7aec50d'
    Secret='newuitQLxHNgbKqLQoEgaWgPj2nanisYy6tNSMpJjY8'
    GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
    Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $10}')
    PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
    file=`cat 80.txt`

    a=`echo "{
        \"touser\" : \"@all\",
        \"msgtype\" : \"text\",   
        \"agentid\" : \"1000002\",
        \"text\" : {           
            \"content\" : \"$file\"}   
      }"`

    /usr/bin/curl --data-ascii "$a" $PURL
    rm -rf 80.txt
else 
    echo "$DATE  检测正常" >> check80.log
fi
