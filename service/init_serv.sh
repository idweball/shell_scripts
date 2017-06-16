#! /bin/bash
#初始化开机自启服务

#获取所有已注册的服务，并将其所有级别开机自启关闭
serv_list=`chkconfig --list | awk '{print$1}'`
for i in ${serv_list};do
    chkconfig --level 0123456 $i off
done

#将部分服务，在级别3开机自启
ex_serv_list="crond sshd network iptables rsyslog auditd"
for i in ex_serv_list;do
    chkconfig --level 3 $i on
done 

exit 0