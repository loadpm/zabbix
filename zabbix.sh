#!/bin/bash
# PLEASE ONLY USE THIS FOR CENTOS 7.X

# Prevents doing this from other account than root
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# Set the locale on your computer (is not the smartest way, I accept sugestions to do it interactivily)
export LC_ALL=en_US.UTF-8
export LANG="en_US.UTF-8"
export LANGUAGE=en_US.UTF-8

# Upgrade system
yum install wget nano -y
yum install epel-release -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum clean all
yum install yum-utils -y
yum-config-manager --enable remi
yum update -y
yum groupinstall development tools -y

#mysql80
rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm
yum update -y
yum install mysql-community-server -y

#php74
yum-config-manager --enable remi-php74
yum -y install php php-pear php-bcmath php-gd php-common php-fpm php-intl php-xml php-opcache php-pdo php-gmp php-process php-pecl-imagick php-devel php-mbstring


### Sed configs
cd /etc
find . -type f -name "php.ini" -exec sed -i 's|short_open_tag = .*|short_open_tag = On|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|max_execution_time = .*|max_execution_time = 900|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|;max_input_vars = .*|max_input_vars = 20000|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|memory_limit = .*|memory_limit = 1024M|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|post_max_size = .*|post_max_size = 1024M|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|display_errors = .*|display_errors = On|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|upload_max_filesize = .*|upload_max_filesize = 1024M|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|;pcre.backtrack_limit= .*|pcre.backtrack_limit=100000|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|;pcre.recursion_limit= .*|pcre.recursion_limit=100000|g' {} \;
find . -type f -name "php.ini" -exec sed -i 's|;realpath_cache_size = .*|realpath_cache_size = 4096k|g' {} \;

#nginx
yum install nginx -y

if [ ! -f /etc/nginx/dhparams.pem ]; then
		
			openssl dhparam -dsaparam -out /etc/nginx/dhparams.pem 4096

		fi

#zabbix


#configs
curl https://raw.githubusercontent.com/loadpm/dor/master/www.conf > /etc/php-fpm.d/www.conf
curl https://raw.githubusercontent.com/SS88UK/VestaCP-Server-Installer/master/CentOS7/nginx.conf > /etc/nginx/nginx.conf
curl https://raw.githubusercontent.com/loadpm/zabbix/master/www.conf > /etc/nginx/conf.d/zabbix.conf

#enable/start service
systectl enable nginx php-fpm mysqld
systemctl start nginx php-fpm mysqld

#disable firewalld
systectl stop firewalld
systectl disable firewalld
