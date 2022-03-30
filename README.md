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
