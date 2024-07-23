# https://www.informaticar.net/install-matrix-synapse-on-ubuntu-20-04/
# https://upcloud.com/community/tutorials/install-matrix-synapse/
# https://matrix.org/docs/guides/free-small-matrix-server
# https://schnerring.net/posts/deploy-a-matrix-homeserver-to-azure-kubernetes-service-aks-with-terraform/

# inbound port:
# from * to 22/tcp for SSH (should be open already)
# from * to 80/tcp for HTTP
# from * to 443/tcp for HTTPS
# from * to 53/udp for DNS
# from * to 8448/tcp for Matrix federation
# from * to 3478/tcp, 5349/tcp, 3478/udp, 5349/udp, 49152-49172/udp for TURN/STUN

# don't forget to:
# 1. add swap
# 2. create duckdns.ini from duckdns_.ini
# 3. create run_duckdns.sh from run_duckdns_.sh
# 3.1 execute run_duckdns.sh

# Inputs:
echo "*** Please enter postgres password:"
stty -echo
read sql_password
stty echo
# name the server
echo "*** Please enter server name:" # <subdomain>.duckdns.org
read server_name
# Certbot creds
echo "*** Please enter duckdns email:"
read duckdns_email

# location to matrix configs
CFG_FILE=/etc/matrix-synapse/homeserver.yaml
CFG_PATH=/etc/matrix-synapse/conf.d

# add matrix packages
echo "*** Installing matrix"
sudo apt install -y lsb-release wget apt-transport-https
sudo wget -O /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main prerelease" |
    sudo tee /etc/apt/sources.list.d/matrix-org.list

# refresh system
sudo apt update
sudo apt upgrade

# install matrix
echo "*** Installing postgres"
sudo apt install matrix-synapse-py3 postgresql python3-psycopg2
sudo cp -f conf.d/*.yaml $CFG_PATH/

# postgres
# create postgres user automatically with password
sudo -u postgres psql -c "CREATE USER \"synapse_user\" WITH PASSWORD '$sql_password';"
# this will prompt for a password for the new user
# sudo -u postgres createuser --pwprompt synapse_user
# create db
sudo -u postgres createdb --encoding=UTF8 --locale=C --template=template0 --owner=synapse_user synapse
# configure postgres
# spaceX3_password: <value>
sudo ./change_field.pl $CFG_PATH/postgres.yaml "   password:" "$sql_password"


# secret
echo "*** Installing secret"
SECRET=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
sudo sh -c "echo registration_shared_secret: $SECRET > $CFG_PATH/macaroon_secret.yaml"

# nginx
echo "*** Installing nginx"
sudo apt install nginx
sudo cp nginx_matrix.conf /etc/nginx/sites-available/matrix
# spaceX4_server_name: <value>;
sudo ./change_field.pl /etc/nginx/sites-available/matrix "    server_name" $server_name\;
sudo ln -s /etc/nginx/sites-available/matrix /etc/nginx/sites-enabled/

# Snap
echo "*** Installing snap"
sudo apt install snapd

# TLS
echo "*** Installing TLS"
chmod 400 duckdns.ini
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo snap install certbot-dns-duckdns
sudo snap set certbot trust-plugin-with-root=ok
sudo snap connect certbot:plugin certbot-dns-duckdns

echo "*** Applying certbot"
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly \
  --non-interactive \
  --agree-tos \
  --email $duckdns_email \
  --preferred-challenges dns \
  --authenticator dns-duckdns \
  --dns-duckdns-credentials duckdns.ini \
  --dns-duckdns-propagation-seconds 60 \
  -d "$server_name"

echo "*** linking ceritifacte to server"
sudo ln -s /etc/letsencrypt/live/${server_name}/fullchain.pem /etc/matrix-synapse/matrixinformaticar.crt
sudo ln -s /etc/letsencrypt/live/${server_name}/privkey.pem /etc/matrix-synapse/matrixinformaticar.key
fullchain="tls_certificate_path: \"/etc/letsencrypt/live/${server_name}/fullchain.pem\""
privkey="tls_private_key_path: \"/etc/letsencrypt/live/${server_name}/privkey.pem\""
sudo sh -c "echo $fullchain > $CFG_PATH/tls.yaml"
sudo sh -c "echo $privkey >> $CFG_PATH/tls.yaml"

# Set cron
echo "*** Installing cron"
sudo cp matrix_cron.service /etc/systemd/system/matrix_cron.service
sudo cp matrix_cron.timer /etc/systemd/system/matrix_cron.timer
sudo systemctl daemon-reload
sudo systemctl enable matrix_cron.timer
sudo systemctl start matrix_cron.timer

# test nginx
echo "*** Testing nginx"
sudo nginx -t 
sudo systemctl restart nginx
sudo systemctl enable nginx

# init matrix
echo "*** Init matrix"
sudo systemctl enable matrix-synapse
sudo systemctl start matrix-synapse
sudo systemctl status matrix-synapse
