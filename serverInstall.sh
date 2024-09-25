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
apt install -y lsb-release 

cat <<EOT > /etc/apt/sources.list
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                                      #
#------------------------------------------------------------------------------#
deb http://deb.debian.org/debian/ bookworm contrib main non-free non-free-firmware
# deb-src http://deb.debian.org/debian/ bookworm contrib main non-free non-free-firmware

deb http://deb.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware
# deb-src http://deb.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware

deb http://deb.debian.org/debian/ bookworm-proposed-updates contrib main non-free non-free-firmware
# deb-src http://deb.debian.org/debian/ bookworm-proposed-updates contrib main non-free non-free-firmware

deb http://deb.debian.org/debian/ bookworm-backports contrib main non-free non-free-firmware
# deb-src http://deb.debian.org/debian/ bookworm-backports contrib main non-free non-free-firmware

deb http://deb.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware
# deb-src http://deb.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmwaRe

#------------------------------------------------------------------------------#
#                      UNOFFICIAL  REPOS                                       #
#------------------------------------------------------------------------------#

EOT

apt update
apt dist-upgrade -y
apt install -y man apt-transport-https lsb-release ca-certificates curl wget dirmngr htop screen unzip nano vim-nox mc git multitail dos2unix python3-pip dnsutils whois lvm2 ufw rsync gnupg pwgen sudo net-tools

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt dist-upgrade -y
#make-cadir /etc/openvpn/easy-rsa2
#cd /etc/ssl/certs
#time openssl dhparam -out dhparam.pem 4096

# Re-generate the RSA and ED25519 keys
rm /etc/ssh/ssh_host_*
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# Only allow secure Diffie-Hellman moduli and download from trusted website
rm /etc/ssh/moduli
for length in 3072 4096 8192; do
        curl https://2ton.com.au/dhparam/$length/ssh >>/etc/ssh/moduli;
done

# Restrict supported key exchange, cipher, and MAC algorithms
echo -e "\n# Restrict key exchange, cipher, and MAC algorithms, as per sshaudit.com\n# hardening guide.\nKexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,gss-curve25519-sha256-,diffie-hellman-group16-sha512,gss-group16-sha512-,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr\nMACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com\nHostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-256-cert-v01@openssh.com" > /etc/ssh/sshd_config.d/ssh-audit_hardening.conf

systemctl restart ssh
echo "If you would like to install Docker, use"
echo "apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

