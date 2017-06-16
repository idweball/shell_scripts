#! /bin/bash
# php-fpm 安装脚本

#退出状态码
E_SUCC=0
E_NOROOT=1
E_NOFILE=2
E_INSTALL_WRONG=3

#权限
if [ ${UID} -ne 0 ];then
    echo "请以Root运行此程序"
    exit ${E_NOROOT}
fi

#工作目录
WORK_DOR="${PWD}"

#安装依赖
yum groupinstall -y "Additioanl Development" "Development tools"
yum install -y epel-release || exit ${E_INSTALL_WRONG}
yum install -y wget mhash libjpeg-devel libmcrypt-devel  openssl-devel 

#软件包存放目录
SRC_DIR="${WORK_DIR}/src"
if [ ! -d ${SRC_DIR} ];then
    mkdir -p ${SRC_DIR}
fi 

#安装libiconv依赖
LIB_ICONV_DOWNLOAD_URL="http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz"
wget ${LIB_ICONV_DOWNLOAD_URL} -P ${SRC_DIR}
if [ $? -ne 0 ];then
    clear
    echo "libiconv 下载失败"
    rm -rf ${SRC_DIR}
    exit ${E_NOFILE}
else
    cd ${SRC_DIR}
    libiconv_tar_name=`basename ${LIB_ICONV_DOWNLOAD_URL}`
    tar xvf ${libiconv_tar_name}
    LIBICONV_NAME=`basename ${libiconv_tar_name} .tar.gz`
fi 

LIB_ICONV_PREFIX="/usr/local/${LIBICONV_NAME}"
cd ${LIBICONV_NAME}
./configure --prefix=${LIB_ICONV_PREFIX}
if [ $? -ne 0 ];then
    clear
    cd ${WORK_DIR}
    rm -rf ${SRC_DIR}
    echo "libiconv configure 失败"
    exit ${E_INSTALL_WRONG}
fi

make && make install 
if [ $? -ne 0 ];then
    clear
    cd ${WORK_DIR}
    rm -rf ${SRC_DIR}
    echo "libiconv 安装失败"
    exit ${E_INSTALL_WRONG}
fi

#检查MySQL
MYSQL_PREFIX="/usr/local/mysql"
while [ ! -d "${MYSQL_PREFIX}" ];do
    echo "在${MYSQL_PREFIX}下未找到MySQL"
    read -p "请指定MySQL的安装路径,例如[/usr/local/mysql]: " MYSQL_PREFIX
done

#PHP安装
cd ${WORK_DIR}
PHP_DWONLOAD_URL="http://mirrors.sohu.com/php/php-5.6.16.tar.gz"
wget ${PHP_DWONLOAD_URL} -P ${SRC_DIR}
if [ $? -ne 0 ];then
    clear
    echo "PHP软件包下载失败"
    rm -rf ${SRC_DIR}
    exit ${E_NOFILE}
else
    php_tar_name=`basename ${PHP_DOWNLOAD_URL}`
    cd ${SRC_DIR}
    tar xvf ${php_tar_name}
    PHP_NAME=`basename ${php_tar_name} .tar.gz`
fi

cd ${PHP_NAME}
PHP_PREFIX="/usr/local/${PHP_NAME}"
./configure  --prefix=${PHP_PREFIX} \
--with-mysql=${MYSQL_PREFIX} \
--with-iconv=${LIB_ICONV_PREFIX} \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--enable-xml \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--with-mcrypt \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--enable-short-tags \
--enable-static \
--with-xsl \
--with-fpm-user=www \
--with-fpm-group=www \
--enable-ftp \
--enable-fpm \
--with-pdo-mysql \
--enable-mbstring \
--with-mysqli \
--with-gettext

if [ $? -ne 0 ];then
    clear
    echo "php configure 失败"
    cd ${WORK_DIR}
    rm -rf ${SRC_DIR}
    exit ${E_INSTALL_WRONG}
fi

make && make install
if [ $? -ne 0 ];then
    clear
    echo "php 安装失败"
    cd ${WORK_DIR}
    rm -rf ${SRC_DIR}
    exit ${E_INSTALL_WRONG}
fi

yes | cp  php.ini-production  ${PHP_PREFIX}/lib/php.ini

cd ${PHP_PREFIX}/etc
yes | cp php-fpm.conf.default php-fpm.conf

exit ${E_SUCC}