#!/bin/bash
#请使用bash运行该脚本
BEGIN_TIME=$(date +%s)
(echo "password";sleep 1;echo "password") | passwd > /dev/null
sed -i "s/`cat /etc/ssh/sshd_config|grep "PermitRootLogin without-password"|head -n 1`/PermitRootLogin yes\n#PermitRootLogin without-password/g" /etc/ssh/sshd_config
service ssh restart
echo "ssh配置更改完毕 下次登录请使用root跟新密码"
sleep 3
SERVERIP=123 #数据中心服地址必须改!注意#前面的空格
apt-get install --yes --force-yes build-essential libncurses5-dev libssl-dev m4 unixodbc unixodbc-dev freeglut3-dev libwxgtk2.8-dev xsltproc fop tk8.5
echo "安装erlang依赖包完成"
sleep 3
wget http://distfiles.macports.org/erlang/otp_src_17.5.tar.gz
tar -zvxf otp_src_17.5.tar.gz
cd otp_src_17.5/
./configure
make
make install
echo "安装erlang完成"
sleep 3
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
apt-get install --yes --force-yes mysql-server
echo "mysql 安装完成"
sleep 3
mkdir -p /data/mysql 
cp -R /var/lib/mysql/* /data/mysql
chown -R mysql:mysql /data/mysql
cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
cp /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/usr.sbin.mysqld.bak
sed -i 's/\/var\/lib\/mysql/\/data\/mysql/g' /etc/mysql/my.cnf
#cat /etc/mysql/my.cnf|grep max_allowed_packet|sed 's/16M/1024M/g'
sed -i "s/`cat /etc/mysql/my.cnf|grep max_allowed_packet |head -n 1`/max_allowed_packet=1024M/g" /etc/mysql/my.cnf
sed -i 's/\/var\/lib\/mysql\/[[:space:]]r/\/data\/mysql\/ r/g' /etc/apparmor.d/usr.sbin.mysqld   
sed -i 's/\/var\/lib\/mysql\/\*\*[[:space:]]rwk/\/data\/mysql\/\*\* rwk/g' /etc/apparmor.d/usr.sbin.mysqld
service mysql restart
echo "mysql 配置完成"
sleep 3
apt-get --yes install sysstat
echo "\$OMFileIOBufferSize 2048k" >> /etc/rsyslog.d/mbzj.conf
echo ":programname, contains, \"xysvr\" @@$SERVERIP" >> /etc/rsyslog.d/mbzj.conf
service rsyslog restart
echo "syslog配置完成"
sleep 3
END_TIME=$(date +%s)
COST_TIME=$(($END_TIME - $BEGIN_TIME))
echo "所有操作完成 用时$COST_TIME秒"
