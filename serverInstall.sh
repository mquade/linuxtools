#!/bin/bash
# Set all locals
timedatectl set-timezone Europe/Berlin && \
	dpkg-reconfigure -f noninteractive tzdata && \
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
	echo 'LANG="de_DE.UTF-8"'>/etc/default/locale && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=de_DE.UTF-8

cp .bashrc* .vimrc /etc/skel
chown root: /etc/skel/*
cp .bashrc* .vimrc /root
chown root: /root/*

for user in $(getent passwd | awk -F: '($3 >= 1000) && ($3 < 65530) {print $1}'); do
	echo Copy files for user: $user
	cp .bashrc* .vimrc /home/$user
	chown $user: /home/$user
done

apt update
apt dist-upgrade
apt install -y apt-transport-https lsb-release ca-certificates curl wget dirmngr htop screen unzip nano vim-nox mc git multitail dos2unix python3-pip openvpn dnsutils whois
# Update source lists
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
wget https://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
cat <<EOT >> /etc/apt/source.list
#------------------------------------------------------------------------------#
# OFFICIAL DEBIAN REPOS 
#------------------------------------------------------------------------------#
###### Debian Main Repos
deb http://deb.debian.org/debian/ stable main contrib non-free
deb-src http://deb.debian.org/debian/ stable main contrib non-free
deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stable-updates main contrib non-free
deb http://deb.debian.org/debian-security stable/updates main
deb-src http://deb.debian.org/debian-security stable/updates main
deb http://ftp.debian.org/debian stretch-backports main
deb-src http://ftp.debian.org/debian stretch-backports main
#------------------------------------------------------------------------------#
# UNOFFICIAL REPOS 
#------------------------------------------------------------------------------#
###### 3rd Party Binary Repos
###Docker CE
deb [arch=amd64] https://download.docker.com/linux/debian stretch stable
###MariaDB
deb [arch=i386,amd64] http://mirror.23media.de/mariadb/repo/10.2/debian stretch main
deb-src [arch=i386,amd64] http://mirror.23media.de/mariadb/repo/10.2/debian stretch main
###nginx
deb [arch=amd64,i386] http://nginx.org/packages/debian/ stretch nginx
deb-src [arch=amd64,i386] http://nginx.org/packages/debian/ stretch nginx
###PostgreSQL
deb [arch=amd64,i386] http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main
###PHP 7.1
deb https://packages.sury.org/php/ stretch main
EOT
apt update
apt dist-upgrade -y
make-cadir /etc/openvpn/easy-rsa2 



