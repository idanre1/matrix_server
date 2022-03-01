#!/bin/bash
# Bridge installation instructions:
# ./install_bridge.sh <bridge_name> <posgres_pass> <domain> [api_id] [api_hash]
#
# Telegram:
# ./install_bridge.sh telegram <posgres_pass> <domain> <api_id> <api_hash>
# Facebook:
# ./install_bridge.sh facebook <posgres_pass> <domain>

# Inits
BRIDGE_NAME=$1
BRIDGE_PASS=$2
DOMAIN=$3
PARAMS_N=3
if [[ $# -eq 3 ]]; then
    echo "*** Non-API parameters supplied"
elif [[ $# -eq 5 ]]; then
    echo "*** API parameters supplied"
    PARAMS_N=5
    API_ID=$4
    API_HASH=$5
else
    echo "*** Error: Not applicable command line arguments"
    exit 1
fi

# Dependencies
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes install python3-virtualenv
$aptyes install python3-dev libolm-dev #build-essential libssl-dev libffi-dev

CFG_FILE=/etc/matrix-synapse/homeserver.yaml
# same path executions
sudo cp mautrix-$BRIDGE_NAME.service /etc/systemd/system/mautrix-${BRIDGE_NAME}.service
sudo systemctl daemon-reload

# clone
sudo adduser --system mautrix-${BRIDGE_NAME} --home /opt/mautrix-${BRIDGE_NAME}
cd /opt/mautrix-${BRIDGE_NAME}
sudo -u mautrix-${BRIDGE_NAME} virtualenv -p /usr/bin/python3 .
sudo -u mautrix-${BRIDGE_NAME} /opt/mautrix-${BRIDGE_NAME}/bin/pip install --upgrade mautrix-${BRIDGE_NAME}[all]

# config db
sudo -u postgres createuser ${BRIDGE_NAME}_user
sudo -u postgres createdb --encoding=UTF8 --locale=C --template=template0 --owner=${BRIDGE_NAME}_user ${BRIDGE_NAME}

# bridge setup
if [[ $PARAMS_N -eq 3 ]]; then
    python3 config_bridge.py --bridge ${BRIDGE_NAME} --name $DOMAIN -p $BRIDGE_PASS
else
    python3 config_bridge.py --bridge ${BRIDGE_NAME} --name $DOMAIN -p $BRIDGE_PASS -i $API_ID --hash $API_HASH
fi

# fold
# python add_bridge_to_server.py -n /opt/mautrix-${BRIDGE_NAME}/registration.yaml > tmp.yaml
# sudo mv tmp.yaml $CFG_FILE
# sudo systemctl enable mautrix-${BRIDGE_NAME}.service
