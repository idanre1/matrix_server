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
echo "*** Installing venv"
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes install python3-virtualenv
$aptyes install python3-dev libolm-dev #build-essential libssl-dev libffi-dev

CFG_FILE=/etc/matrix-synapse/conf.d/apps.yaml
# same path executions
sudo cp ${BRIDGE_NAME}_matrix.service /etc/systemd/system/${BRIDGE_NAME}_matrix.service
sudo systemctl daemon-reload

# clone
echo "*** add user"
sudo adduser --system ${BRIDGE_NAME}_matrix --home /opt/${BRIDGE_NAME}_matrix

echo "*** venv"
pushd /opt/${BRIDGE_NAME}_matrix
sudo -u ${BRIDGE_NAME}_matrix virtualenv -p /usr/bin/python3 .
sudo -u ${BRIDGE_NAME}_matrix /opt/${BRIDGE_NAME}_matrix/bin/pip install --upgrade ${BRIDGE_NAME}_matrix
popd

# config db
echo "*** postgres"
sudo -u postgres createuser ${BRIDGE_NAME}_user
sudo -u postgres createdb --encoding=UTF8 --locale=C --template=template0 --owner=${BRIDGE_NAME}_user ${BRIDGE_NAME}
sudo -u postgres psql -c "ALTER USER ${BRIDGE_NAME}_user PASSWORD '$BRIDGE_PASS';"

# bridge setup
echo "*** bridge setup"
sudo -u ${BRIDGE_NAME}_matrix cp /opt/${BRIDGE_NAME}_matrix/lib/python3.8/site-packages/${BRIDGE_NAME}_matrix/example-config.yaml /opt/${BRIDGE_NAME}_matrix/config.yaml
if [[ $PARAMS_N -eq 3 ]]; then
    sudo -u ${BRIDGE_NAME}_matrix python3 config_bridge.py --bridge ${BRIDGE_NAME} --name $DOMAIN -p $BRIDGE_PASS --filename /opt/${BRIDGE_NAME}_matrix/config.yaml
else
    sudo -u ${BRIDGE_NAME}_matrix python3 config_bridge.py --bridge ${BRIDGE_NAME} --name $DOMAIN -p $BRIDGE_PASS --filename /opt/${BRIDGE_NAME}_matrix/config.yaml -i $API_ID --hash $API_HASH
fi

# bridge registration
echo "*** bridge registration"
pushd /opt/${BRIDGE_NAME}_matrix
sudo -u ${BRIDGE_NAME}_matrix /opt/${BRIDGE_NAME}_matrix/bin/python -m ${BRIDGE_NAME}_matrix -g
popd
sudo chgrp $USER /opt/${BRIDGE_NAME}_matrix/registration.yaml

# add bridge to matrix
echo "*** add bridge to matrix"
python3 add_bridge_to_server.py -n /opt/${BRIDGE_NAME}_matrix/registration.yaml > tmp.yaml
sudo mv tmp.yaml $CFG_FILE
sudo systemctl restart matrix-synapse
sudo systemctl enable ${BRIDGE_NAME}_matrix.service
sudo systemctl start ${BRIDGE_NAME}_matrix.service

