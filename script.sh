#!/bin/sh

#Backup files
TMP=/var/tmp/br/
mkdir -p $TMP

function backup {
cp -a $1 $TMP
}

#lockfile
if [ -e $TMP/.lock ] ; then
 echo already run
 exit 10
fi
touch $TMP/.lock

#BReak thingsA
#MYSQL
 CNF=/etc/my.cnf
 backup $CNF
 sed -e '/^\[mysqld\]/,/^\[/ {/port/s/3306/3007/g}' $CNF > $CNF
 mv $CNF $CNF.change304323
 service mysql stop
 service mysqld stop

# postifx

 PF=/usr/sbin/postfix
 backup $PF
 mv $PF $TMP/postfix.backup2

#iptable rule
iptables -I INPUT 1 -p tcp --dport 80 -j REJECT
iptables -I INPUT 1 -p tcp --dport 80 -j LOG --log-prefix "Denied TCP: "

#DElete myself
rm script.sh
