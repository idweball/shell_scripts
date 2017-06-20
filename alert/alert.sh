#! /bin/sh
#将本脚本放置于/etc/profile.d目录下。只要登陆登陆加载shell,就会发送邮件

#获取登陆信息
login_ip=`who -u am i | egrep -o "\<([0-9]{1,3}\.){3}[0-9]{1,3}\>"`
login_time=`date "+%Y-%m-%d %H:%M:%S"`

#获取本机IP
local_ip=`ifconfig eth0 | awk -F "[ :]+"  'NR==2 {print$4}'`

#发送邮件
to_address=1942314542@qq.com #收件人地址
echo | mail -s "login alert from ${local_ip}"  ${to_address} << EOF
login time: ${login_time}
login ip: ${login_ip}
EOF
