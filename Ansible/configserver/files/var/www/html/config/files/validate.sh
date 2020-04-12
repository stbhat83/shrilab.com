#!/bin/bash

#############################################
##Purpose: Validate the server provisioning##
##Contact: opsadm@shrilab.com              ##
#############################################

/usr/bin/wget -P /var/tmp/ http://192.168.0.1:8080/config/md5sum.txt > /dev/null 2>&1

OSSHKEY=`/bin/grep authorized_keys /var/tmp/md5sum.txt | cut -d "=" -f2`
ODNS=`/bin/grep "resolv.conf" /var/tmp/md5sum.txt | cut -d "=" -f2`
OREPO=`/bin/grep "CentOS-Base.repo" /var/tmp/md5sum.txt | cut -d "=" -f2`
OSSHCONFIG=`/bin/grep "sshd_config" /var/tmp/md5sum.txt | cut -d "=" -f2`
OSUDOERS=`/bin/grep "sudoers" /var/tmp/md5sum.txt | cut -d "=" -f2`

CSSHKEY=`/usr/bin/md5sum /home/opsadm/.ssh/authorized_keys | /bin/awk '{ print $1 }'`
CDNS=`/usr/bin/md5sum /etc/resolv.conf | /bin/awk '{ print $1 }'`
CREPO=`/usr/bin/md5sum /etc/yum.repos.d/CentOS-Base.repo | /bin/awk '{ print $1 }'`
CSSHCONFIG=`/usr/bin/md5sum /etc/ssh/sshd_config | /bin/awk '{ print $1 }'`
CSUDOERS=`/usr/bin/md5sum /etc/sudoers | /bin/awk '{ print $1 }'`

if [ "$OSSHKEY" == "$CSSHKEY" ]
        then
                echo -e "\e[1;32m SSH keys ==> OK \e[0m"
	else
		echo -e "\e[1;31m SSH keys ==> Not Matching \e[0m"
fi


if [ "$ODNS" == "$CDNS" ]
        then
                echo -e "\e[1;32m DNS resolver ==> OK \e[0m"
	else
		echo -e "\e[1;31m DNS resolver ==> Not Matching \e[0m"
fi

if [ "$OREPO" == "$CREPO" ]
        then
                echo -e "\e[1;32m Repo Config ==> OK \e[0m"
	else
		echo -e "\e[1;31m Repo Config ==> Not Matching \e[0m"
fi

if [ "$OSSHCONFIG" == "$CSSHCONFIG" ]
	then
                echo -e "\e[1;32m SSH Config ==> OK \e[0m"
	else
		echo -e "\e[1;31m SSH Config ==> Not Matching \e[0m"
fi

if [ "$OSUDOERS" == "$CSUDOERS" ]
	then
                echo -e "\e[1;32m Sudoers File ==> OK \e[0m"
	else
		echo -e "\e[1;31m Sudoers File ==> Not Matching \e[0m"
fi

##Check SELinux status
/usr/sbin/getenforce | grep "Disabled" > /dev/null 2>&1
SELINUXSTATUS=`echo $?`
SELINUXOK=0

	if [ "$SELINUXSTATUS" == "$SELINUXOK" ]
		then
			echo -e "\e[1;32m SELinux Status ==> Disabled \e[0m"
		else
			echo -e "\e[1;31m SELinux Status ==> Enabled \e[0m"
	fi

##Check IPTables (v4 and bv6) are stopped and disabled

/sbin/service iptables status > /dev/null 2>&1
iptables=`echo $?`
iptables_ok=3
	
	if [ "$iptables" -eq "$iptables_ok" ]
		then 
			echo -e "\e[1;32m IPTABLES == > Not Running \e[0m"
			/sbin/chkconfig --list iptables | grep "on" > /dev/null 2>&1
			iptables_ser=`echo $?`
			iptables_serv_ok=0
			
				if [ "$iptables_ser" -ne "$iptables_serv_ok" ]
					then
						echo -e "\e[1;32m IPTABLES Status== > Disabled \e[0m"
					else
						echo -e "\e[1;31m IPTABLES Status ==> Enabled \e[0m"
				fi
		else
			echo -e "\e[1;31m IPTABLES ==> Running \e[0m"
	fi

/sbin/service ip6tables status > /dev/null 2>&1
ip6tables=`echo $?`
ip6tables_ok=3
	
	if [ "$ip6tables" -eq "$ip6tables_ok" ]
		then 
			echo -e "\e[1;32m IP6TABLES == > Not Running \e[0m"
			/sbin/chkconfig --list ip6tables | grep "on" > /dev/null 2>&1
			ip6tables_ser=`echo $?`
			ip6tables_serv_ok=0
			
				if [ "$ip6tables_ser" -ne "$ip6tables_serv_ok" ]
					then
						echo -e "\e[1;32m IP6TABLES Status== > Disabled \e[0m"
					else
						echo -e "\e[1;31m IP6TABLES Status ==> Enabled \e[0m"
				fi
		else
			echo -e "\e[1;31m IP6TABLES ==> Running \e[0m"
	fi

##Check NetworkManager Service
/sbin/chkconfig --list | grep NetworkManager > /dev/null 2>&1
nm=`echo $?`
ok=0
	if [ "$nm" -ne "$ok" ]
		then
			echo -e "\e[1;32m NetworkManager == > Not Installed \e[0m"
		else
			/sbin/service NetworkManager status > /dev/null 2>&1
			NetworkManager=`echo $?`
			NetworkManager_ok=0
	
				if [ "$NetworkManager" -ne "$NetworkManager_ok" ]
					then 
						echo -e "\e[1;32m NetworkManager == > Not Running \e[0m"
						/sbin/chkconfig --list NetworkManager | grep "on" > /dev/null 2>&1
						NetworkManager_ser=`echo $?`
						NetworkManager_serv_ok=0
			
							if [ "$NetworkManager_ser" -ne "$NetworkManager_serv_ok" ]
								then
									echo -e "\e[1;32m NetworkManager Status== > Disabled \e[0m"
								else
									echo -e "\e[1;31m NetworkManager Status ==> Enabled \e[0m"
							fi
					else
						echo -e "\e[1;31m NetworkManager ==> Running \e[0m"
				fi
	fi
## Check user "opsadm"

SUID=`/bin/grep opsadm /etc/passwd | cut -d ":" -f3`
SGID=`/bin/grep opsadm /etc/passwd | cut -d ":" -f4`
	if [ "$SUID" -eq "2001" ]
		then
			if [ "$SGID" -eq "2001" ]
 				then 
					echo -e "\e[1;32m OPSADM UID/GID == > OK \e[0m"
				else
					echo -e "\e[1;31m OPSADM GID == > False \e[0m"
			fi
		else
			echo -e "\e[1;31m OPSADM UID == > False \e[0m"
	fi
