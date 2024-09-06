#!/bin/bash

set -e

echo "Installing Radius"
wget -q "https://raw.githubusercontent.com/radius-project/radius/main/deploy/install.sh" -O - | /bin/bash

if [ -n "${_REMOTE_USER}" ]; then
    echo "Installing Bicep"
    su ${_REMOTE_USER} -c "rad bicep download"
fi
