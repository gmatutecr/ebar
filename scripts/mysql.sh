MYSQL_URL="https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz"
VERSION=5.6.46
OS=linux-glibc2.12
ARCH=x86_64

#cd /tmp && { wget $MYSQL_URL ; cd -; }

#groupadd mysql
#useradd -r -g mysql -s /bin/false mysql
cd /usr/local
#tar xvf "/tmp/mysql-$VERSION-$OS-$ARCH.tar.gz"
ln -s "mysql-$VERSION-$OS-$ARCH" mysql
export PATH=$PATH:/usr/local/mysql/bin
cd mysql
mkdir mysql-files
chown mysql:mysql mysql-files
chmod 750 mysql-files
bin/mysqld --initialize --user=mysql
bin/mysql_ssl_rsa_setup
bin/mysqld_safe --user=mysql &
