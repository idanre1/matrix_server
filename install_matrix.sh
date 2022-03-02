# https://www.informaticar.net/install-matrix-synapse-on-ubuntu-20-04/
# https://upcloud.com/community/tutorials/install-matrix-synapse/
# https://matrix.org/docs/guides/free-small-matrix-server
# https://schnerring.net/posts/deploy-a-matrix-homeserver-to-azure-kubernetes-service-aks-with-terraform/

# inbound port:
# from * to 22/tcp for SSH (should be open already)
# from * to 80/tcp for HTTP
# from * to 443/tcp for HTTPS
# from * to 8448/tcp for Matrix federation
# from * to 3478/tcp, 5349/tcp, 3478/udp, 5349/udp, 49152-49172/udp for TURN/STUN

# don't forget to add swap


# Inputs:
echo "*** Please enter postgres password:"
stty -echo
read sql_password
stty echo
# name the server
echo "*** Please enter server name:"
read server_name

CFG_FILE=/etc/matrix-synapse/homeserver.yaml

# Add pgp keys
sudo update
sudo apt install lsb-release wget apt-transport-https
sudo wget -qO /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
sudo echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/matrix-org.list

# refresh system
sudo update
sudo upgrade

# matrix
sudo apt install matrix-synapse-py3 postgresql python3-psycopg2
sudo -i -u postgres
#psql -c "CREATE USER \"synapse_user\" WITH PASSWORD '$sql_password';"
#psql -c "CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER \"synapse_user\";"
# this will prompt for a password for the new user
createuser --pwprompt synapse_user
# create db
createdb --encoding=UTF8 --locale=C --template=template0 --owner=synapse_user synapse
exit # from postgres user


# secret
SECRET=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
sudo ./uncomment.pl $CFG_FILE registration_shared_secret
sudo ./change_field.pl $CFG_FILE "registration_shared_secret:" $SECRET
sudo ./delete_region.pl $CFG_FILE database:
sudo sh -c "cat synapse-postgres.config >> $CFG_FILE"
sudo ./change_field.pl $CFG_FILE "   password" $sql_password

# nginx
sudo apt install nginx
sudo cp nginx_matrix.conf /etc/nginx/sites-available/matrix
sudo ./change_field.pl /etc/nginx/sites-available/matrix SERVER_NAME $server_name\;
sudo ln -s /etc/nginx/sites-available/matrix /etc/nginx/sites-enabled/
sudo nginx -t # test server
sudo systemctl restart nginx
sudo systemctl enable nginx

# TLS
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo ln -s /etc/letsencrypt/live/matrix.regev.tk/fullchain.pem /etc/matrix-synapse/matrixinformaticar.crt
sudo ln -s /etc/letsencrypt/live/matrix.regev.tk/privkey.pem /etc/matrix-synapse/matrixinformaticar.key
sudo ./uncomment.pl $CFG_FILE tls_certificate_path
sudo ./change_field.pl $CFG_FILE tls_certificate_path: "/etc/letsencrypt/live/matrix.regev.tk/fullchain.pem"
sudo ./uncomment.pl $CFG_FILE tls_private_key_path
sudo ./change_field.pl $CFG_FILE tls_private_key_path: "/etc/letsencrypt/live/matrix.regev.tk/privkey.pem"

# matrix custome configs
sudo ./change_value.pl $CFG_FILE "server_name: \"SERVERNAME\"" "server_name: $server_name"
sudo ./uncomment.pl $CFG_FILE allow_public_rooms_over_federation
sudo ./uncomment.pl $CFG_FILE enable_registration
sudo ./uncomment.pl $CFG_FILE suppress_key_server_warning

# Set cron
sudo cp matrix_cron.service /etc/systemd/system/matrix_cron.service
sudo cp matrix_cron.timer /etc/systemd/system/matrix_cron.timer
sudo systemctl daemon-reload
sudo systemctl enable matrix_cron.timer
sudo systemctl start matrix_cron.timer

# init matrix
sudo systemctl enable matrix-synapse
sudo systemctl start matrix-synapse
sudo systemctl status matrix-synapse
