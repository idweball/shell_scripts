#! /bin/bash
#MySQL 二进制免编译安装

#退出状态码
E_SUCC=0
E_NOFILE=1
E_NOROOT=2
E_INSTALL_WORNG=3

#工作目录
WORK_DIR="${PWD}"

#权限判断
if [ ${UID} -ne 0 ];then
    echo "请以ROOT用户运行此脚本"
    exit ${E_NOROOT}
fi

#MySQL安装目录初始化
MYSQL_PREFIX="/usr/local/mysql"
if [ -d ${MYSQL_PREFIX} ];then
    read -t 3 -p "MySQL已存在，是否删除并继续？[y/n]: "  i
    if [[ $i == 'y' || $i == 'Y' ]];then
        rm -rf ${MYSQL_PREFIX}
    else
        clear
        echo "退出安装"
        exit ${E_INSTALL_WORNG}
    fi
fi 

#下载文件存放目录
SRC_DIR="${WORK_DIR}/src"
if [ ! -d "${SRC_DIR}" ];then
    mkdir -p ${SRC_DIR}
fi 

#MySQL的用户和组初始化
MYSQL_USER="mysql"
MYSQL_GROUP="mysql"
if `id ${MYSQL_USER} &>/dev/null`;then
	group=`id ${MYSQL_USER} | awk -F "[()]" '{print$6}'`
	if [ ${group} != ${MYSQL_GROUP} ];then
		usermod ${MYSQL_USER} -g ${MYSQL_GROUP} &>/dev/null
		if [ $? -ne 0 ];then
			groupadd ${MYSQL_GROUP}
			usermod ${MYSQL_USER} -g ${MYSQL_GROUP}
		fi
	fi
else
    groupadd ${MYSQL_GROUP}
	useradd ${MYSQL_USER}  -g ${MYSQL_GROUP} -s /sbin/nologin -M
fi

#基本工具初始化
yum groupinstall -y "Development tools" "Additional Development" || exit ${E_NOFILE}
yum install -y wget

#MySQL软件包下载，解压
MYSQL_DOWNLOAD_URL="http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz"
wget ${MYSQL_DOWNLOAD_URL} -P ${SRC_DIR}
if [ $? -ne 0 ];then
    echo "MySQL 软件包下载失败"
    rm -rf ${SRC_DIR}
    exit ${E_NOFILE}
else
    cd ${SRC_DIR}
    mysql_tar_name=`basename ${MYSQL_DOWNLOAD_URL}`
    tar xvf ${mysql_tar_name}
    MYSQL_NAME=`basename ${mysql_tar_name} .tar.gz`
    mv ${MYSQL_NAME} ${MYSQL_PREFIX}
    chown -R ${MYSQL_USER}:${MYSQL_GROUP}  ${MYSQL_PREFIX}
fi 

#MySQL数据存放目录初始化
MYSQL_DATA_DIR="/home/data/mysql"
while [ -d ${MYSQL_DATA_DIR} ];do 
    read -p "MySQL数据存放目录${MYSQL_DATA_DIR}已经存在,请重新指定目录: " MYSQL_DATA_DIR
done
mkdir -p ${MYSQL_DATA_DIR}
chown -R ${MYSQL_USER}:${MYSQL_GROUP} ${MYSQL_DATA_DIR}

cd ${MYSQL_PREFIX}

if [ ! -f "${MYSQL_PREFIX}/scripts/mysql_install_db" ];then
    clear 
    echo "找不到MySQL初始化文件mysql_install_db"
    echo "安装失败"
    cd ${WORK_DIR}
    rm -rf ${SRC_DIR}
    rm -rf ${MYSQL_PREFIX}
    exit ${E_NOFILE}
fi 

#MySQL初始化
./scripts/mysql_install_db --basedir=${MYSQL_PREFIX} --user=${MYSQL_USER} --datadir=${MYSQL_DATA_DIR}

if [ $? -ne 0 ];then
    clear 
    echo "MySQL初始化失败"
    echo "MySQL安装失败"
    cd ${WORK_DIR}
    rm -rf ${SRC_DIR}
    rm -rf ${MYSQL_PREFIX}
    exit ${E_INSTALL_WORNG}
fi

#MySQL配置文件初始化
cat > /etc/my.cnf << EOF
[mysql]
socket=${MYSQL_DATA_DIR}/mysql.sock

[mysqld]
bind-address=127.0.0.1
datadir=${MYSQL_DATA_DIR}
socket=${MYSQL_DATA_DIR}/mysql.sock
user=${MYSQL_USER}
symbolic-links=0

[mysqld_safe]
log-error=${MYSQL_DATA_DIR}/mysqld.log
pid-file=${MYSQL_DATA_DIR}/mysqld.pid
EOF

#MySQL服务注册
yes|cp -a support-files/mysql.server /etc/init.d/mysqld
exit ${E_SUCC}
