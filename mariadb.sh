#!/usr/bin/env bash

sudo apt-get -y install mariadb-server # mariadb-client
ss -tulpn | grep LISTEN
systemctl status mysql
sudo mysql
exit

cat /etc/mysql/my.cnf | grep -v "#" | grep -v "^$"
cat /etc/mysql/mariadb.cnf | grep "^[^#;]"
cat /etc/mysql/conf.d/mysql.cnf | grep "^[^#;]"
ls -lah /etc/mysql/mariadb.conf.d/
cat /etc/mysql/mariadb.conf.d/50-server.cnf | grep "^[^#;]"
sudo cp /etc/mysql/mariadb.conf.d/50-server.cnf{,.default}

HUSHHUSH=$(base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 16)
echo $HUSHHUSH
echo "export HUSHHUSH=$HUSHHUSH" >> ~/.bashrc

sudo apt-get -y install expect
sudo expect <<EOF
set timeout 1
spawn mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\n"
expect "Switch to unix_socket authentication"
send "y\n"
expect "Change the root password?"
send "y\n"
expect "New password:"
send "$HUSHHUSH\n"
expect "Re-enter new password:"
send "$HUSHHUSH\n"
expect "Remove anonymous users?"
send "y\n"
expect "Disallow root login remotely?"
send "y\n"
expect "Remove test database and access to it?"
send "y\n"
expect "Reload privilege tables now?"
send "y\n"
expect eof
EOF
mysql -uroot -p$HUSHHUSH
exit

wget http://mysqltuner.pl/ -O mysqltuner.pl
wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O basic_passwords.txt
wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv -O vulnerabilities.csv
perl mysqltuner.pl --user root --pass $HUSHHUSH

# General recommendations:
#     Add skip-innodb to MySQL configuration to disable InnoDB
#     MySQL was started within the last 24 hours: recommendations may be inaccurate
#     Configure your accounts with ip or subnets only, then update your configuration with skip-name-resolve=ON
#     Performance schema should be activated for better diagnostics
#     Be careful, increasing innodb_log_file_size / innodb_log_files_in_group means higher crash recovery mean time
# Variables to adjust:
#     skip-name-resolve=ON
#     performance_schema=ON
#     innodb_log_file_size should be (=32M) if possible, so InnoDB total log file size equals 25% of buffer pool size.
#     innodb_log_buffer_size (> 16M)

sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null <<'EOF'
skip-name-resolve
performance_schema = on
innodb_buffer_pool_size = 2G
innodb_log_file_size = 512M
EOF

sudo systemctl restart mysql

