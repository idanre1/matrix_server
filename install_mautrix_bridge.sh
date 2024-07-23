#!/bin/bash
# Bridge installation instructions:
# ./install_mautrix_bridge.sh <bridge_name> <posgres_pass> <server_name> [api_id] [api_hash]
#
# Telegram:
# ./install_mautrix_bridge.sh telegram <posgres_pass> <server_name> <api_id> <api_hash>
# Facebook:
# ./install_mautrix_bridge.sh facebook <posgres_pass> <server_name>
# Twitter:
# ./install_mautrix_bridge.sh twitter <posgres_pass> <server_name>

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
echo "*** Installing venv"
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes install python3-virtualenv
$aptyes install python3-dev libolm-dev #build-essential libssl-dev libffi-dev

CFG_FILE=/etc/matrix-synapse/conf.d/apps.yaml
# same path executions
sudo cp mautrix-$BRIDGE_NAME.service /etc/systemd/system/mautrix-${BRIDGE_NAME}.service
sudo systemctl daemon-reload

# clone
echo "*** add user"
sudo adduser --system mautrix-${BRIDGE_NAME} --home /opt/mautrix-${BRIDGE_NAME}

echo "*** venv"
pushd /opt/mautrix-${BRIDGE_NAME}
sudo -u mautrix-${BRIDGE_NAME} virtualenv -p /usr/bin/python3 .
sudo -u mautrix-${BRIDGE_NAME} /opt/mautrix-${BRIDGE_NAME}/bin/pip install --upgrade mautrix-${BRIDGE_NAME}[all]
popd

# config db
echo "*** postgres"
sudo -u postgres createuser ${BRIDGE_NAME}_user
sudo -u postgres createdb --encoding=UTF8 --locale=C --template=template0 --owner=${BRIDGE_NAME}_user ${BRIDGE_NAME}
sudo -u postgres psql -c "ALTER USER ${BRIDGE_NAME}_user PASSWORD '$BRIDGE_PASS';"

# bridge setup
echo "*** bridge setup"
sudo -u mautrix-${BRIDGE_NAME} cp /opt/mautrix-${BRIDGE_NAME}/example-config.yaml /opt/mautrix-${BRIDGE_NAME}/config.yaml
if [[ $PARAMS_N -eq 3 ]]; then
    sudo -u mautrix-${BRIDGE_NAME} python3 config_bridge.py --bridge ${BRIDGE_NAME} --name $DOMAIN -p $BRIDGE_PASS
else
    sudo -u mautrix-${BRIDGE_NAME} python3 config_bridge.py --bridge ${BRIDGE_NAME} --name $DOMAIN -p $BRIDGE_PASS -i $API_ID --hash $API_HASH
fi

# bridge registration
echo "*** bridge registration"
pushd /opt/mautrix-${BRIDGE_NAME}
sudo -u mautrix-${BRIDGE_NAME} /opt/mautrix-${BRIDGE_NAME}/bin/python -m mautrix_${BRIDGE_NAME} -g
popd
sudo chgrp $USER /opt/mautrix-${BRIDGE_NAME}/registration.yaml

# add bridge to matrix
echo "*** add bridge to matrix"
python3 add_bridge_to_server.py -n /opt/mautrix-${BRIDGE_NAME}/registration.yaml > tmp.yaml
sudo mv tmp.yaml $CFG_FILE
sudo systemctl restart matrix-synapse
sudo systemctl enable mautrix-${BRIDGE_NAME}.service
sudo systemctl start mautrix-${BRIDGE_NAME}.service
