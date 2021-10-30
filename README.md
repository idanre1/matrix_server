# matrix_server
Matrix (element.io) server on azure, with bridges  
Also add binder/ashmem kernel modules to azure kernel (dynamically loaded) for anbox

## How to renew certificates
%> sudo crontab -e
0 12 * * * /usr/bin/certbot renew --quiet

