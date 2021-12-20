#!/bin/sh

aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
$aptyes update
$aptyes upgrade
$aptyes dist-upgrade
sudo systemctl stop mautrix-telegram

cd /opt/mautrix-telegram
source bin/activate
sudo -u mautrix-telegram bin/pip install --upgrade mautrix-telegram[all]
alembic -x config=/opt/mautrix-telegram/config.yaml upgrade head

sudo systemctl restart matrix-synapse
sleep 5

sudo systemctl start mautrix-telegram
