#!/usr/bin/env bash

sudo install -m 0755 -d /etc/apt/keyrings

# mongodb

sudo curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc -o /etc/apt/keyrings/mongodb
echo \
    "deb [ signed-by=/etc/apt/keyrings/mongodb ] \
    http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | \
    sudo tee /etc/apt/sources.list.d/mongodb.list > /dev/null
sudo apt-get update
sudo apt-get -y install mongodb-org

sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod

mongosh

# opensearch

sudo curl -fsSL https://artifacts.opensearch.org/publickeys/opensearch.pgp -o /etc/apt/keyrings/opensearch
echo \
    "deb [ signed-by=/etc/apt/keyrings/opensearch ] \
    https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" | \
    sudo tee /etc/apt/sources.list.d/opensearch.list

sudo apt-get update
sudo apt list -a opensearch
sudo env OPENSEARCH_INITIAL_ADMIN_PASSWORD=$HUSH apt-get -y install opensearch=2.13.0

sudo systemctl daemon-reload
sudo systemctl enable opensearch
sudo systemctl start opensearch
sudo systemctl status opensearch

curl -X GET https://localhost:9200 -u "admin:$HUSH" --insecure
curl -X GET https://localhost:9200/_cat/plugins?v -u "admin:$HUSH" --insecure

# setting for graylog

sudo cat /etc/opensearch/opensearch.yml | grep "^[^#;]"
sudo cat /etc/opensearch/jvm.options | grep "^[^#;]"
sudo cp /etc/opensearch/opensearch.yml{,.original}
sudo cp /etc/opensearch/jvm.options{,.original}

sudo tee /etc/opensearch/opensearch.yml > /dev/null <<'EOF'
cluster.name: graylog
node.name: server
discovery.type: single-node
network.host: 127.0.0.1
action.auto_create_index: false
plugins.security.disabled: true
EOF
sudo cat /etc/opensearch/opensearch.yml.original | grep "^[^#;]" | \
    sudo tee -a /etc/opensearch/opensearch.yml > /dev/null

# sudo sed -i "s|-Xms1g|-Xms4g|g" /etc/opensearch/jvm.options
# sudo sed -i "s|-Xmx1g|-Xmx4g|g" /etc/opensearch/jvm.options

sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p

sudo systemctl restart opensearch
sudo netstat -tulpn | grep java

curl -X GET http://localhost:9200 -u "admin:$HUSH"
curl -X GET http://localhost:9200/_cat/plugins?v -u "admin:$HUSH"


# graylog

wget https://packages.graylog2.org/repo/packages/graylog-6.0-repository_latest.deb
sudo dpkg -i graylog-6.0-repository_latest.deb
sudo apt-get update
sudo apt-get -y install graylog-server 

SHA256SUM=$(echo "$HUSH" | tr -d '\n' | sha256sum | cut -d' ' -f1)

sudo cat /etc/graylog/server/server.conf | grep "^[^#;]"
sudo cp /etc/graylog/server/server.conf{,.original}
sudo sed -i "s|#http_bind_address = 127.0.0.1.*|http_bind_address = 0.0.0.0:9000|g" /etc/graylog/server/server.conf
sudo sed -i "s|password_secret =.*|password_secret = $HUSHHUSHHUSH|g" /etc/graylog/server/server.conf
sudo sed -i "s|root_password_sha2 =.*|root_password_sha2 = $SHA256SUM|g" /etc/graylog/server/server.conf
sudo sed -i "s|#message_journal_max_size = 5gb.*|message_journal_max_size = 1gb|g" /etc/graylog/server/server.conf

sudo systemctl daemon-reload
sudo systemctl enable graylog-server
sudo systemctl start graylog-server
sudo systemctl status graylog-server

cat /var/log/graylog-server/server.log | grep "Initial configuration is accessible" | sed -nr "s|.+and password '(.+)'.+|\1|p"

INITIAL_HUSH=$(cat /var/log/graylog-server/server.log | grep "Initial configuration is accessible" | sed -nr "s|.+and password '(.+)'.+|\1|p")
curl http://admin:$INITIAL_HUSH@0.0.0.0:9000

sudo tee /etc/nginx/sites-available/graylog.devops.constanta.ua > /dev/null <<'EOF'
server {
    listen 443 ssl http2;
    server_name graylog.devops.constanta.ua;
    location / {
        proxy_pass http://127.0.0.1:9000;
        include proxy_params;
    }
    access_log /var/log/nginx/graylog.devops.constanta.ua_access.log;
    error_log /var/log/nginx/graylog.devops.constanta.ua_error.log;
}
EOF
sudo ln -s /etc/nginx/sites-available/graylog.devops.constanta.ua /etc/nginx/sites-enabled/graylog.devops.constanta.ua
sudo nginx -t
sudo systemctl reload nginx

# clients rsyslog

sudo apt-get -y install rsyslog

sudo cp /etc/logrotate.d/rsyslog{,.original}
sudo tee -a /etc/logrotate.d/rsyslog > /dev/null <<EOF
/var/log/syslog
{
        rotate 7
        size 100M
        daily
        missingok
        notifempty
        delaycompress
        compress
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
}
/var/log/mail.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/cron.log
{
        rotate 4
        weekly
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
}
EOF

cat /etc/rsyslog.conf | grep "^[^#;]"
sudo cp /etc/rsyslog.conf{,.original}
sudo tee -a /etc/rsyslog.conf > /dev/null <<EOF
*.* @$SERVER:514;RSYSLOG_SyslogProtocol23Format
EOF
sudo systemctl restart rsyslog

tail -n 50 /var/log/graylog-server/server.log
tail -f /var/log/graylog-server/server.log
sudo systemctl restart graylog-server