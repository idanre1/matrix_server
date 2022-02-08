#!/bin/sh

echo "*** apt upgrade"
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
$aptyes update
$aptyes upgrade
$aptyes dist-upgrade
$aptyes autoremove
sudo systemctl stop mautrix-telegram

echo "*** mautrix-telegram upgrade"
cd /opt/mautrix-telegram
source bin/activate
sudo -u mautrix-telegram bin/pip install --upgrade mautrix-telegram[all]
#alembic -x config=/opt/mautrix-telegram/config.yaml upgrade head

echo "*** matrix-synapse restart"
sudo systemctl restart matrix-synapse
echo "*** matrix-synapse restart...(sleep)"
sleep 5

echo "*** mautrix-telegram restart"
sudo systemctl start mautrix-telegram

