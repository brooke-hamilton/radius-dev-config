#!/bin/bash

# Description: Creates a new Backstage application in a specified directory (defaults to "testapp").
# Usage: ./create_testapp.sh <app directory>

appdir=${1:-testapp}

k3d cluster delete
k3d cluster create
rad install kubernetes
dapr init -k

if [ ! -d "$appdir" ]; then
    mkdir "$appdir"
fi

npx @backstage/create-app@latest --path "./$appdir"