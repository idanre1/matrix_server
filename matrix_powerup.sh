#!/bin/bash

BOTS=`cat matrix_bots.list`

echo "*** matrix-synapse start"
sudo systemctl start matrix-synapse
echo "*** matrix-synapse start...(sleep)"
sleep 5

for bot in $BOTS; do
	echo "*** $bot start"
	sudo systemctl start $bot
	sleep 2
done

