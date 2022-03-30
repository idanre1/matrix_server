#!/bin/bash

BOTS=`cat matrix_upgrade.list`

echo "*** matrix-synapse stop"
sudo systemctl stop matrix-synapse

echo "*** apt upgrade"
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
forces='-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ' # https://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install

#$aptyes update
#sudo dpkg --configure -a
#$aptyes upgrade $forces
#$aptyes dist-upgrade $forces
#$aptyes autoremove

for bot in $BOTS; do
	sudo systemctl stop $bot

	echo "*** $bot upgrade"
	cd /opt/$bot
	source bin/activate
	sudo -u $bot bin/pip install --upgrade $bot[all]
	#alembic -x config=/opt/mautrix-telegram/config.yaml upgrade head
	deactivate
done

echo "*** matrix-synapse restart"
sudo systemctl start matrix-synapse
echo "*** matrix-synapse restart...(sleep)"
sleep 5

for bot in $BOTS; do
	echo "*** $bot restart"
	sudo systemctl start $bot
	sleep 2
done

