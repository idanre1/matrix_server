#!/bin/bash

BOTS=`cat matrix_bots.list`

matrix_shutdown.sh

echo "*** apt upgrade"
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
forces='-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ' # https://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install

#$aptyes update
#sudo dpkg --configure -a
#$aptyes upgrade $forces
#$aptyes dist-upgrade $forces
#$aptyes autoremove

for bot in $BOTS; do
	echo "*** $bot upgrade"
	cd /opt/$bot
	source bin/activate
	sudo -u $bot bin/pip install --upgrade $bot[all]
	#alembic -x config=/opt/mautrix-telegram/config.yaml upgrade head
	deactivate
done

matrix_powerup.sh
