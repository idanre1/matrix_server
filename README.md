# matrix_server
Matrix (element.io) server 

## How to renew certificates
sudo crontab -e
0 12 * * * /usr/bin/certbot renew --quiet
