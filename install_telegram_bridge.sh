#!/usr/bin/sh
# Dependencies
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes install python3-virtualenv
$aptyes install python3-dev libolm-dev #build-essential libssl-dev libffi-dev

CFG_FILE=/etc/matrix-synapse/homeserver.yaml

# clone
cd ~
mkdir bridge_telegram
cd bridge_telegram
virtualenv -p /usr/bin/python3 .
source ./bin/activate
pip install --upgrade mautrix-telegram[all]

# config
sudo -i -u postgres
createuser --pwprompt telegram_user
createdb --encoding=UTF8 --locale=C --template=template0 --owner=telegram_user telegram
exit # from postgres user

# systemd
sudo adduser --system mautrix-telegram --home /opt/mautrix-telegram


# bridge setup
# python config_bridge.py --name matrix.domain.com -p postgress_pass -i <api_id> --hash <api_hash>

# python add_bridge_to_server.py -n /nas/bridge_telegram/registration.yaml > tmp.yaml
# sudo mv tmp.yaml $CFG_FILE
