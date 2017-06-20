#! /bin/sh
#�����ű�������/etc/profile.dĿ¼�¡�ֻҪ��½��½����shell,�ͻᷢ���ʼ�

#��ȡ��½��Ϣ
login_ip=`who -u am i | egrep -o "\<([0-9]{1,3}\.){3}[0-9]{1,3}\>"`
login_time=`date "+%Y-%m-%d %H:%M:%S"`

#��ȡ����IP
local_ip=`ifconfig eth0 | awk -F "[ :]+"  'NR==2 {print$4}'`

#�����ʼ�
to_address=1942314542@qq.com #�ռ��˵�ַ
echo | mail -s "login alert from ${local_ip}"  ${to_address} << EOF
login time: ${login_time}
login ip: ${login_ip}
EOF
