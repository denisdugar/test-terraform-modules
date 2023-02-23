#!/bin/bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https -y
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install kibana
sudo ufw allow 5601
sudo apt-get install -y nginx apache2-utils
sudo echo "server.port: 5601
server.host: 0.0.0.0
elasticsearch.hosts:
  [
    \"http://master0:9200\",
    \"http://master1:9200\",
    \"http://node0:9200\",
    \"http://node1:9200\",
    \"http://node2:9200\",
    \"http://node3:9200\",
  ]
logging:
  appenders:
    file:
      type: file
      fileName: /var/log/kibana/kibana.log
      layout:
        type: json
  root:
    appenders:
      - default
      - file
pid.file: /run/kibana/kibana.pid" | sudo tee /etc/kibana/kibana.yml
export SERNAME=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sudo echo "server {
    listen 80;
    server_name $SERNAME;
#    listen [::]:80 default_server;
    location / {
        proxy_pass http://0.0.0.0:4180;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
server {
    listen 8080;
    server_name $SERNAME;
#    listen [::]:8080 default_server;
    location / {
        proxy_pass http://0.0.0.0:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}" | sudo tee /etc/nginx/sites-available/kibana
sudo ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/
sudo service nginx restart
sudo service kibana restart
wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.2.1/oauth2-proxy-v7.2.1.linux-amd64.tar.gz
tar -xvf oauth2-proxy-v7.2.1.linux-amd64.tar.gz
sudo echo "[Unit]
Description=oauth2 service
[Service]
User=ubuntu
WorkingDirectory=/oauth2-proxy-v7.2.1.linux-amd64
ExecStart=/oauth2-proxy-v7.2.1.linux-amd64/oauth2-proxy --email-domain=\"*\" --upstream=\"http://localhost:8080/\" --redirect-url=\"http://$SERNAME/oauth2/callback\" --cookie-secret=secretsecretsecr --cookie-name=\"_oauth2_proxy\" --cookie-secure=false --provider=github --client-id=\"0f3f43c239bfe9e7c66a\" --client-secret=\"8f8c5bf1e9a7f636559583e57c1bc03d8e6e644d\"
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/oauth.service
sudo systemctl daemon-reload
sudo systemctl start oauth.service