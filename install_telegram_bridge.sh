#!/usr/bin/sh
# Dependencies
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes install python3-virtualenv
$aptyes install python3-dev libolm-dev #build-essential libssl-dev libffi-dev

CFG_FILE=/etc/matrix-synapse/homeserver.yaml
# same path executions
sudo cp mautrix-telegram.service /etc/systemd/system/mautrix-telegram.service
sudo systemctl daemon-reload

# clone
sudo adduser --system mautrix-telegram --home /opt/mautrix-telegram
cd /opt/mautrix-telegram
sudo -u mautrix-telegram virtualenv -p /usr/bin/python3 .
sudo -u mautrix-telegram /opt/mautrix-telegram/bin/pip install --upgrade mautrix-telegram[all]

# config db
sudo -i -u postgres
createuser --pwprompt telegram_user
createdb --encoding=UTF8 --locale=C --template=template0 --owner=telegram_user telegram
exit # from postgres user

# bridge setup
# python config_bridge.py --name matrix.domain.com -p postgress_pass -i <api_id> --hash <api_hash>
# source /opt/mautrix-telegram/bin/activate
# alembic -x config=/opt/mautrix-telegram/config.yaml upgrade head
# deactivate

# fold
# python add_bridge_to_server.py -n /opt/mautrix-telegram/registration.yaml > tmp.yaml
# sudo mv tmp.yaml $CFG_FILE
# sudo systemctl enable mautrix-telegram.service