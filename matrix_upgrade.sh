#!/bin/sh

echo "*** apt upgrade"
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
forces='-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes' # https://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install

$aptyes update
$aptyes upgrade $forces
$aptyes dist-upgrade $forces


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

