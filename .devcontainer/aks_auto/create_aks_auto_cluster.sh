#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <resource group name>"
    exit 1
fi
resource_group="$1"

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

cluster_name=$(mktemp -u "$resource_group-XXXX")
echo "Creating cluster $cluster_name"
az aks create --resource-group "$resource_group" --name "$cluster_name" --sku automatic --generate-ssh-keys -l southcentralus 
az aks get-credentials --resource-group "$resource_group" --name "$cluster_name"
