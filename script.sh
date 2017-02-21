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

#Break things
#MYSQL
 CNF=/etc/my.cnf
 backup $CNF
 sed -e '/^\[mysqld\]/,/^\[/ {/port/s/3306/3007/g}' $CNF > $CNF
 mv $CNF $CNF.chg.992348
 cat << EOF > $CNF
 [mysqld]
 datadir = /var/lib/mySQL
EOF
 service mysqld stop

# postfix
 PF=/usr/sbin/postfix
 backup $PF
 mv $PF $TMP/postfix.backup2

#iptable rule
backup /etc/sysconfig/iptables
iptables -I INPUT 1 -p tcp --dport 80 -j REJECT
iptables -I INPUT 1 -p tcp --dport 80 -j LOG --log-prefix "Denied TCP: "

#www
ls -lad /var/www/html > $TMP/www_html.perm
chmod 000 /var/www/html

#Delete myself
rm -f script.sh
