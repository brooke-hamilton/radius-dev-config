#!/bin/bash

set -e

# Ensure that the user is logged in to the Azure CLI.
if ! az account show &> /dev/null; then
    echo "Please log in to the Azure CLI before running this script: az login"
    exit 1
fi

# Ensure that the aks auto feature is registered
aks_registration_state=$(az feature show --namespace Microsoft.ContainerService --name AutomaticSKUPreview --query 'properties.state' -o tsv)
if [[ $aks_registration_state != "Registered" ]]; then
    echo "The AKS Automatic feature is not registered in the Azure CLI. Please register before running this script."
    exit 1
fi

echo "AKS Automatic feature is registered"