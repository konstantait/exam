#!/usr/bin/env bash

# https://computingpost.medium.com/configure-graylog-nginx-proxy-with-lets-encrypt-ssl-5b3bd6f9694e

PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-12};echo;)
SECRET_KEY=$(< /dev/urandom tr -dc A-Za-z0-9- | head -c${1:-96};echo;)
SHA256SUM=$(echo "$PASSWORD" | sha256sum | cut -d' ' -f1)

echo "export OPENSEARCH_PASS=$PASSWORD" >> ~/.bashrc
echo "export GREYLOG_PASS=$PASSWORD" >> ~/.bashrc
echo "export GREYLOG_SECRET_KEY=$SECRET_KEY" >> ~/.bashrc

sudo apt-get -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

# MongoDB 7
sudo curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc -o /etc/apt/keyrings/mongodb.asc
sudo chmod a+r /etc/apt/keyrings/mongodb.asc
echo \
  "deb [ signed-by=/etc/apt/keyrings/mongodb.asc ] http://repo.mongodb.org/apt/debian \
  bookworm/mongodb-org/7.0 main" | \
  sudo tee /etc/apt/sources.list.d/mongodb.list > /dev/null
sudo apt-get update
sudo apt-get -y install mongodb-org

sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod

mongosh

# OpenSearch 2.13
sudo curl -fsSL https://artifacts.opensearch.org/publickeys/opensearch.pgp -o /etc/apt/keyrings/opensearch.asc
echo \
  "deb [ signed-by=/etc/apt/keyrings/opensearch.asc ] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt \
  stable main" | \
  sudo tee /etc/apt/sources.list.d/opensearch.list > /dev/null
sudo apt-get update
sudo env OPENSEARCH_INITIAL_ADMIN_PASSWORD=$OPENSEARCH_PASS apt-get -y install opensearch=2.13.0

sudo cat /etc/opensearch/opensearch.yml | grep "^[^#;]"
sudo cat /etc/opensearch/jvm.options | grep "^[^#;]"
sudo cp /etc/opensearch/opensearch.yml{,.default}
sudo cp /etc/opensearch/jvm.options{,.default}

sudo systemctl enable opensearch
sudo systemctl start opensearch
sudo systemctl status opensearch

curl -X GET https://localhost:9200 -u "admin:$OPENSEARCH_PASS" --insecure
curl -X GET https://localhost:9200/_cat/plugins?v -u "admin:$OPENSEARCH_PASS" --insecure


# Graylog 6
sudo sysctl -w vm.max_map_count=262144
sudo echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
sysctl -p

sudo sed -i -e '1 s|^|cluster.name: graylog\n|;' /etc/opensearch/opensearch.yml
sudo sed -i -e '1 s|^|node.name: graylog.konstanta.pp.ua\n|;' /etc/opensearch/opensearch.yml
sudo sed -i -e '1 s|^|discovery.type: single-node\n|;' /etc/opensearch/opensearch.yml
sudo sed -i -e '1 s|^|network.host: 127.0.0.1\n|;' /etc/opensearch/opensearch.yml
sudo sed -i -e '1 s|^|action.auto_create_index: false\n|;' /etc/opensearch/opensearch.yml
sudo sed -i -e '1 s|^|plugins.security.disabled: true\n|;' /etc/opensearch/opensearch.yml

sudo sed -i "s|-Xms1g|-Xms4g|g" /etc/opensearch/jvm.options
sudo sed -i "s|-Xmx1g|-Xmx4g|g" /etc/opensearch/jvm.options

sudo systemctl restart opensearch

curl -X GET http://localhost:9200 -u "admin:$OPENSEARCH_PASS"
curl -X GET http://localhost:9200/_cat/plugins?v -u "admin:$OPENSEARCH_PASS"

wget https://packages.graylog2.org/repo/packages/graylog-6.0-repository_latest.deb
sudo dpkg -i graylog-6.0-repository_latest.deb
sudo apt-get update
sudo apt-get -y install graylog-server 

sudo cat /etc/graylog/server/server.conf | grep "^[^#;]"
sudo cp /etc/graylog/server/server.conf{,.default}
sudo cp /etc/graylog/server/server.conf.default /etc/graylog/server/server.conf
sudo sed -i "s|#http_bind_address = 127.0.0.1.*|http_bind_address = 0.0.0.0:9000|g" /etc/graylog/server/server.conf
sudo sed -i "s|password_secret =.*|password_secret = $SECRET_KEY|g" /etc/graylog/server/server.conf
sudo sed -i "s|root_password_sha2 =.*|root_password_sha2 = $SHA256SUM|g" /etc/graylog/server/server.conf

sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
sudo systemctl status graylog-server.service

sudo cat /var/log/graylog-server/server.log | \
  grep "Initial configuration is accessible" | \
  sed -nr "s|.+and password '(.+)'.+|\1|p"
