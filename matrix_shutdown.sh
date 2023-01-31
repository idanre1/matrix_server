#!/bin/bash

BOTS=`cat matrix_bots.list`

echo "*** matrix-synapse stop"
sudo systemctl stop matrix-synapse

for bot in $BOTS; do
	echo "*** Stop bot: $bot"
	sudo systemctl stop $bot
done

