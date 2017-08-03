#!/bin/bash

export PATH="/bin:/usr/bin:/usr/sbin:/sbin"

FILE_DIR=('/bin' '/usr/bin' '/sbin' '/usr/sbin' '/etc/passwd')
MD5_DB='md5.db'

clear
echo "md5sum is staring..."

for i in ${FILE_DIR[@]};do
	if [ -d "$i" ];then
		for j in `ls $i`;do
			if [ -d "$i/$j" ];then
				continue
			fi
			md5sum "$i/$j" 1>> ${MD5_DB}
		done
	else
		if [ -e "$i" ];then
			md5sum $i 1>> ${MD5_DB}
		fi
	fi
done
echo ""
echo "md5sum is done."
