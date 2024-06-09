#!/usr/bin/env bash

# client

cd ~
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian12_all.deb
sudo dpkg -i zabbix-release_6.4-1+debian12_all.deb
sudo apt-get update
sudo apt-get -y install zabbix-agent2 zabbix-agent2-plugin-*
sudo systemctl status zabbix-agent2
cat /lib/systemd/system/zabbix-agent2.service

cat /etc/zabbix/zabbix_agent2.conf | grep "^[^#;]"
sudo cp /etc/zabbix/zabbix_agent2.conf{,.original}
sudo tee /etc/zabbix/zabbix_agent2.conf > /dev/null <<EOF
PidFile=/var/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=$SERVER
ServerActive=$SERVER
Timeout = 10
Hostname=node1.devops.constanta.ua
Include=/etc/zabbix/zabbix_agent2.d/*.conf
PluginSocket=/run/zabbix/agent.plugin.sock
ControlSocket=/run/zabbix/agent.sock
Include=/etc/zabbix/zabbix_agent2.d/plugins.d/*.conf
EOF
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2


# server

# sudo mkdir -p /etc/zabbix
# sudo mkdir -p /var/log/zabbix
# sudo mkdir -p /var/run/zabbix
# sudo chown -R zabbix:zabbix /var/log/zabbix
# sudo chown -R zabbix:zabbix /var/run/zabbix
# sudo chmod -R 775 /var/log/zabbix/
# sudo chmod -R 775 /var/run/zabbix/

sudo cp /usr/local/etc/zabbix_server.conf{,.original}
sudo ln -s /usr/local/etc/zabbix_server.conf /etc/zabbix/zabbix_server.conf
sudo tee /etc/zabbix/zabbix_server.conf > /dev/null <<EOF
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/var/run/zabbix/zabbix_server.pid
SocketDir=/var/run/zabbix
DBName=zabbix
DBUser=zabbix
DBPassword=$HUSH
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
Timeout=10
FpingLocation=/usr/bin/fping
Fping6Location=/usr/bin/fping6
LogSlowQueries=3000
StatsAllowedIP=127.0.0.1,$LAN_NETWORK
EOF

sudo tee /lib/systemd/system/zabbix-server.service > /dev/null <<'EOF'
[Unit]
Description=Zabbix Server
After=syslog.target
After=network.target
After=mysql.service
After=mysqld.service
After=mariadb.service

[Service]
Environment="CONFFILE=/etc/zabbix/zabbix_server.conf"
EnvironmentFile=-/etc/default/zabbix-server
Type=forking
Restart=on-failure
PIDFile=/run/zabbix/zabbix_server.pid
KillMode=control-group
ExecStart=/usr/local/sbin/zabbix_server -c $CONFFILE
ExecStop=/bin/sh -c '[ -n "$1" ] && kill -s TERM "$1"' -- "$MAINPID"
RestartSec=10s
TimeoutSec=infinity

[Install]
WantedBy=multi-user.target
EOF

# sudo systemctl daemon-reload

sudo systemctl enable zabbix-server
sudo systemctl restart zabbix-server
sudo systemctl status zabbix-server

