!#/bin/bash

echo "*****Disabling IPTabled (v4 and v6)*****"
/sbin/iptables -F > /dev/nulll 2>&1
/sbin/service iptables stop > /dev/null 2>&1
/sbin/chkconfig iptables off > /dev/null 2>&1
/sbin/chkconfig ip6tables off > /dev/null 2>&1
/sbin/service ip6tables stop > /dev/null 2>&1

echo "*****Disabling NetworkManager*****"
/sbin/service NetworkManager stop > /dev/null 2>&1
/sbin/chkconfig NetworkManager off > /dev/null 2>&1

echo "*****Desabling SELinux*****"
/usr/sbin/setenforce 0 > /dev/null 2>&1
/bin/sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux > /dev/null 2>&1

echo "*****Creating "opsadm" group and user*****"
/usr/sbin/groupadd -g 2001 opsadm > /dev/null 2>&1
/usr/sbin/useradd -u 2001 -c "Operations Team" -g 2001 -m -s /bin/bash opsadm > /dev/null 2>&1

echo "*****Copy SSH Public key*****"
/bin/mkdir /home/opsadm/.ssh/ > /dev/nulll 2>&1
/bin/chmod 700 /home/opsadm/.ssh/ > /dev/nulll 2>&1
/bin/chown opsadm.opsadm /home/opsadm/.ssh/ > /dev/nulll 2>&1
/usr/bin/wget -P /home/opsadm/.ssh/ http://192.168.0.1:8080/config/authorized_keys > /dev/null 2>&1
/bin/chmod 644 /home/opsadm/.ssh/authorized_keys > /dev/nulll 2>&1
/bin/chown opsadm.opsadm /home/opsadm/.ssh/authorized_keys > /dev/nulll 2>&1

echo "*****Create Yum rep config*****"
/bin/mkdir -p /etc/yum.repos.d/bak > /dev/nulll 2<&1
/bin/mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/ > /dev/nulll 2<&1
/usr/bin/wget -P /etc/yum.repos.d/ http://192.168.0.1:8080/config/CentOS-Base.repo > /dev/null 2>&1
/bin/chmod 644 /etc/yum.repos.d/CentOS-Base.repo > /dev/null 2>&1

echo "*****Download Sudoers file*****"
/usr/bin/wget -P /var/tmp/ http://192.168.0.1:8080/config/sudoers > /dev/null 2>&1
/bin/cp -f /var/tmp/sudoers /etc/sudoers

echo "*****Copy SSHD configuaration*****"
/usr/bin/wget -P /var/tmp/ http://192.168.0.1:8080/config/sshd_config > /dev/null 2>&1
/bin/cp -f /var/tmp/sshd_config /etc/ssh/sshd_config

echo "*****Copy Resolv.conf*****"
/usr/bin/wget -P /var/tmp/ http://192.168.0.1:8080/config/resolv.conf > /dev/null 2>&1
/bin/cp -f /var/tmp/resolv.conf /etc/resolv.conf > /dev/null 2>&1

/sbin/reboot
