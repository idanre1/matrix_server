#!/bin/bash

BOTS=`cat matrix_bots.list`

curr_path=`pwd`
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
	cd /opt/$bot/bin
	source activate
	sudo -u $bot pip3 install --upgrade pip
	sudo -u $bot pip3 install --upgrade $bot[all]
	#alembic -x config=/opt/mautrix-telegram/config.yaml upgrade head
	deactivate
done

cd $curr_path
matrix_powerup.sh
