#!/bin/bash

export PATH='/bin:/usr/bin:/sbin:/usr/sbin'
FILE_DIR=('/bin' '/usr/bin' '/usr/sbin' '/sbin' '/etc/passwd')
MD5_DB='md5.db'
CHECK_LOG='check.log'

if [ -e "${CHECK_LOG}" ];then
	rm -rf ${CHECK_LOG}
	touch ${CHECK_LOG}
else
	touch ${CHECK_LOG}
fi

if [ ! -e "${MD5_DB}" ];then
	echo "Not Found MD5 database" > ${CHECK_LOG}
	exit 1
fi

clear
echo "check md5 starting..."
for i in "${FILE_DIR[@]}";do
	if [ -d "$i" ];then
		for j in `ls $i`;do
			if [ -d "$i/$j" ];then
				continue
			fi
			md5=`md5sum "$i/$j"`
			grep "${md5}" ${MD5_DB} &>/dev/null
			if [ $? -ne 0 ];then
				echo "[EXCEPTION] ${md5}" >> ${CHECK_LOG}
			fi
		done
	else
		if [ -e "$i" ];then
			md5=`md5sum $i`
			grep "${md5}" ${MD5_DB} &>/dev/null
			if [ $? -ne 0 ];then
				echo "[EXCEPTION] ${md5}" >> ${CHECK_LOG}
			fi
		fi
	fi
done
echo "check md5 done"
