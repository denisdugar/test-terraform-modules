#!/bin/bash
sudo apt update
sudo apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip \
                 nfs-common \
                 cifs-utils \
                 curl \
                 mysql-client-core-8.0
sudo mkdir /var/www
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_endpoint}:/ /var/www
curl https://wordpress.org/latest.tar.gz | sudo tar zx -C /var/www
echo "<VirtualHost *:80>
    DocumentRoot /var/www/wordpress
    <Directory /var/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /var/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>" | sudo tee -a /etc/apache2/sites-available/wordpress.conf
mysql -h ${db_endpoint} -P 3306 -u ${db_username} -p${db_password} -e "CREATE DATABASE wordpress"
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo systemctl restart apache2
sudo cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
sudo sed -i 's/database_name_here/wordpress/' /var/www/wordpress/wp-config.php
sudo sed -i 's|username_here|'${db_username}'|' /var/www/wordpress/wp-config.php
sudo sed -i 's|password_here|'${db_password}'|' /var/www/wordpress/wp-config.php
sudo sed -i 's|localhost|'${db_endpoint}'|' /var/www/wordpress/wp-config.php
sudo sed -i "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );/" /var/www/wordpress/wp-config.php
sudo echo "define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'SAVEQUERIES', true );" | sudo tee -a /var/www/wordpress/wp-config.php
sudo systemctl restart apache2
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install filebeat -y
sudo echo "filebeat:
  # List of prospectors to fetch data.
  inputs:
    # This is a text lines files harvesting definition
    -
     paths:
       - /var/www/html/wordpress/wp-content/debug.log
     fields_under_root: true
     ignore_older: 24h
     document_type: WP
    -
     paths:
       - /var/log/apache2/*.log
     fields_under_root: true
     ignore_older: 24h
     document_type: apache
     registry_file: /var/lib/filebeat/registry
output:
  logstash:
    hosts: [\"${ip_logstash0}:5044\", \"${ip_logstash1}:5044\"]" | sudo tee /etc/filebeat/filebeat.yml
sudo filebeat modules enable system
sudo filebeat setup --pipelines --modules system
sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=[\"master0\", \"master1\", \"node0\", \"node1\", \"node2\", \"node3\"]'
sudo systemctl start filebeat && sudo systemctl enable filebeat
