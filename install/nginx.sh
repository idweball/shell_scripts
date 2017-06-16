#! /bin/bash

#设置搜索路径
PATH="/sbin:/usr/sbin:/bin:/usr/bin"
export PATH

#退出状态码
E_SUCC=0
E_NOFILE=1
E_NOROOT=2
E_INSTALL_WRONG=3

#工作路径
WORK_DIR="${PWD}"

#检查用户权限
if [ $UID -ne 0 ];then
	echo "请以root用户运行此脚本"
fi

#源码存放目录
SRC_DIR="${PWD}/src"
if [ ! -d "${SRC_DIR}" ];then
	mkdir -p ${SRC_DIR}
fi

#Nginx守护进程的用户和组
NGX_USER="www"
NGX_GROUP="www"
if `id ${NGX_USER} &>/dev/null`;then
	group=`id ${NGX_USER} | awk -F "[()]" '{print$6}'`
	if [ ${group} != ${NGX_GROUP} ];then
		usermod ${NGX_USER} -g ${NGX_GROUP} &>/dev/null
		if [ $? -ne 0 ];then
			groupadd ${NGX_GROUP}
			usermod ${NGX_USER} -g ${NGX_GROUP}
		fi
	fi
else
	groupadd ${NGX_GROUP}
	useradd ${NGX_USER} -g ${NGX_GROUP} -s /sbin/nologin -M
fi

#开发环境及依赖的软件包安装
yum groupinstall -y "Additional Development" "Development tools"
yum install -y epel-release || exit ${E_INSTALL_WRONG}
yum install -y openssl-devel pcre-devel wget

#下载Nginx软件包，并解压
NGX_DOWNLOAD_URL="http://nginx.org/download/nginx-1.11.2.tar.gz"
wget ${NGX_DOWNLOAD_URL} -P ${SRC_DIR}
if [ $? -eq 0 ];then
	if [ "${PWD}" != "${SRC_DIR}" ];then
		cd ${SRC_DIR}
	fi
	ngx_tar_name=`basename ${NGX_DOWNLOAD_URL}`
	tar xvf ${ngx_tar_name}
	NGX_NAME=`basename ${ngx_tar_name} .tar.gz`
	SRC_NGX_DIR="${SRC_DIR}/${NGX_NAME}"
else
	rm -rf ${SRC_DIR}
	echo "Nginx 下载失败"
	exit ${E_NOFILE}
fi

#Nginx的安装路径
NGX_PREFIX="/usr/local/${NGX_NAME}"
cd ${SRC_NGX_DIR}

#检测configure文件是否存在
tag=0
for i in `ls`;do
	if [ -f $i ];then
		if [ "$i" == "configure" ];then
			echo $i
			tag=1
		fi
	fi
done
if [ ${tag} -ne 1 ];then
	cd ${WORK_DIR}
	rm -rf ${SRC_DIR}
	echo "未找到configure文件"
	exit ${E_NOFILE}
fi

#编译参数指定
./configure --prefix=${NGX_PREFIX} \
--user=${NGX_USER} \
--group=${NGX_GROUP} \
--with-http_ssl_module \
--with-http_stub_status_module

if [ $? -ne 0 ];then
	clear
	echo "Nginx configure 失败"
	exit ${E_INSTALL_WRONG}
fi

#进行编译
make
if [ $? -ne 0 ];then
	clear
	echo "Nginx 编译失败"
	exit ${E_INSTALL_WRONG}
fi

#安装
make install
if [ $? -ne 0 ];then
	clear
	echo "Nginx 安装失败"
	exit ${E_INSTALL_WRONG}
fi

#清理安装残留
cd ${WORK_DIR}
rm -rf ${SRC_DIR}

#通知用户安装完成，及必要的参数
clear
echo "Nginx 安装成功"
echo "Nginx 安装路径:${NGX_PREFIX}"
echo "Nginx deamon用户:${NGX_USER}"
echo "Nginx deamon组:${NGX_GROUP}"
exit ${E_SUCC}
