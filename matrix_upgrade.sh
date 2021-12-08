#!/bin/sh

aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
$aptyes update
$aptyes upgrade
$aptyes dist-upgrade

cd /opt/mautrix-telegram
source bin/activate

sudo systemctl stop mautrix-telegram
sudo systemctl restart matrix-synapse
sleep 5

sudo systemctl start mautrix-telegram
