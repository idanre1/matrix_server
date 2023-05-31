# matrix_server
Matrix (element.io) server on azure, with bridges  
Also add binder/ashmem kernel modules to azure kernel (dynamically loaded) for anbox

## How to renew certificates
%> sudo crontab -e
0 12 * * * /usr/bin/certbot renew --quiet

## How to register new user
```bash
cd /etc/matrix-synapse/
register_new_matrix_user -c homeserver.yaml http://localhost:8008
```
  Follow the cli instructions

# Postgres
Shell
```bash
 sudo -u postgres -i psql
 ```
## Postgres upgrade
Every version upgrade there is a need to also upgrade the database.  
### Migrate postgres12 to postgres14 example
Turn off matrix
```bash
sudo pg_dropcluster 14 main --stop
sudo pg_upgradecluster 12 main
sudo pg_dropcluster 12 main
```
Turn on matrix
