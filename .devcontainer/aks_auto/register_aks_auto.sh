#!/bin/bash

# Description: Registers the AKS Automatic features in the Azure CLI.
# See https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-automatic-deploy?pivots=azure-cli
# Usage: ./install_aks_auto.sh

set -e

# Ensure that the user is logged in to the Azure CLI.
if ! az account show &> /dev/null; then
    echo "Please log in to the Azure CLI before running this script: az login"
    exit 1
fi

az extension add --name aks-preview
az feature register --namespace Microsoft.ContainerService --name EnableAPIServerVnetIntegrationPreview
az feature register --namespace Microsoft.ContainerService --name NRGLockdownPreview
az feature register --namespace Microsoft.ContainerService --name SafeguardsPreview
az feature register --namespace Microsoft.ContainerService --name NodeAutoProvisioningPreview
az feature register --namespace Microsoft.ContainerService --name DisableSSHPreview
az feature register --namespace Microsoft.ContainerService --name AutomaticSKUPreview
az feature show --namespace Microsoft.ContainerService --name AutomaticSKUPreview

# Wait until all features have finished registering
while [[ $(az feature show --namespace Microsoft.ContainerService --name AutomaticSKUPreview --query 'properties.state') == '"Registering"' ]]; do
    sleep 5
    echo "Registering"
done

az provider register --namespace Microsoft.ContainerService
echo "Azure provider registered"