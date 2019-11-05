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
apt dist-upgrade -y
apt install -y apt-transport-https lsb-release ca-certificates curl wget dirmngr htop screen unzip nano vim-nox mc git multitail dos2unix python3-pip openvpn dnsutils whois lvm2 ufw
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
wget -q -O- https://download.docker.com/linux/debian/gpg | apt-key add -
wget -q -O- https://nginx.org/keys/nginx_signing.key | apt-key add -
wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add -
wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

cat <<EOT > /etc/apt/sources.list
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                    
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://deb.debian.org/debian/ buster main contrib non-free
deb-src http://deb.debian.org/debian/ buster main contrib non-free

deb http://deb.debian.org/debian/ buster-updates main contrib non-free
deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free

deb http://deb.debian.org/debian-security buster/updates main
deb-src http://deb.debian.org/debian-security buster/updates main

deb http://ftp.debian.org/debian buster-backports main
deb-src http://ftp.debian.org/debian buster-backports main

deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main

deb http://security.debian.org/ buster/updates main contrib non-free

#------------------------------------------------------------------------------#
#                      UNOFFICIAL  REPOS                       
#------------------------------------------------------------------------------#

###### 3rd Party Binary Repos
###Docker CE
deb [arch=amd64] https://download.docker.com/linux/debian buster stable

###MariaDB
deb [arch=amd64] http://mirror.23media.de/mariadb/repo/10.2/debian stretch main
deb-src [arch=amd64] http://mirror.23media.de/mariadb/repo/10.2/debian stretch main

###nginx
deb [arch=amd64] http://nginx.org/packages/debian/ buster nginx
deb-src [arch=amd64] http://nginx.org/packages/debian/ stretch nginx

###PHP
deb https://packages.sury.org/php/ buster main

###PostgreSQL
deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main

EOT

apt update
apt dist-upgrade -y
make-cadir /etc/openvpn/easy-rsa2 
cd /etc/ssl/certs
time openssl dhparam -out dhparam.pem 4096
rm /etc/ssh/moduli
for length in 2048 3072 4096 8192; do
	curl https://2ton.com.au/dhparam/$length/ssh >>/etc/ssh/moduli;
done
systemctl restart ssh
