#!/bin/bash

# Description: Creates a new Backstage application in a folder named "testapp" relative to the current directory.
# Usage: ./create_testapp.sh <app directory>

appdir=${1:-testapp}

if ! k3d cluster list | grep -q 'No clusters found'; then
    k3d cluster create
    rad install kubernetes
    dapr init -k
else
    echo "k3d cluster is already running."
fi

if [ ! -d "$appdir" ]; then
    mkdir "$appdir"
fi

npx @backstage/create-app@latest --path "./$appdir"