#!/bin/bash

set -e

# Ensure that the user is logged in to the Azure CLI.
if ! az account show &> /dev/null; then
    echo "Please log in to the Azure CLI before running this script: az login"
    exit 1
fi

# Ensure that the aks auto feature is registered
if [[ $(az feature show --namespace Microsoft.ContainerService --name AutomaticSKUPreview --query 'properties.state' -o tsv) != "Registered" ]]; then
    echo "User is not registered. Please register before running this script."
    exit 1
fi