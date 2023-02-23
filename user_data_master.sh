#!/bin/bash
sudo hostnamectl set-hostname $(curl 169.254.169.254/latest/meta-data/tags/instance/Name)
sudo echo "$(curl 169.254.169.254/latest/meta-data/tags/instance/Name)" | sudo tee /etc/hostname
sudo echo "127.0.1.1 $(curl 169.254.169.254/latest/meta-data/tags/instance/Name)" | sudo tee -a /etc/hosts
sudo apt-get update
sudo apt-get install -y gawk
sudo apt-get install -y openjdk-8-jdk
sudo apt-get install -y apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update
sudo apt-get install elasticsearch
export HOSTNAME=$(cat /etc/hostname)
export HOSTIP=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
sudo echo "cluster.name: es-cluster
node.name: $HOSTNAME
node.master: true
node.data: false
path.data: /var/lib/elasticsearch/
path.logs: /var/log/elasticsearch/
network.host: $HOSTIP
http.port: 9200
transport.port: 9300
discovery.seed_hosts:
  [\"master0\", \"master1\", \"node0\", \"node1\", \"node2\", \"node3\"]
discovery.zen.minimum_master_nodes: 2
cluster.initial_master_nodes: [\"master0\", \"master1\"]" | sudo tee /etc/elasticsearch/elasticsearch.yml
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service