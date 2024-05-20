#!/usr/bin/env bash

sudo apt-get -y install lsb-release ca-certificates curl gnupg2


curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get -y install mongodb-org

sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod

mongosh


curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | \
   sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring

echo "deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" | sudo tee /etc/apt/sources.list.d/opensearch-2.x.list
sudo apt-get update
sudo env OPENSEARCH_INITIAL_ADMIN_PASSWORD=3fKSX6g4ZRd0 apt-get -y install opensearch=2.13.0

sudo systemctl enable opensearch
sudo systemctl start opensearch
sudo systemctl status opensearch
curl -X GET https://localhost:9200 -u 'admin:3fKSX6g4ZRd0' --insecure

cat /etc/opensearch/opensearch.yml | grep "^[^#;]"
cp /etc/opensearch/opensearch.yml{,.default}

