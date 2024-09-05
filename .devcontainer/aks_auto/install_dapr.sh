#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <resource group name>"
    exit 1
fi

resource_group=$1
aks_cluster=$(kubectl config current-context)

echo "Installing Dapr on cluster $aks_cluster in resource group $resource_group"
az k8s-extension create --cluster-type managedClusters \
--cluster-name "$aks_cluster" \
--resource-group "$resource_group" \
--name dapr \
--extension-type Microsoft.Dapr \
--auto-upgrade-minor-version false

# kubectl get nodes && kubectl get namespaces && kubectl get pods -n dapr-system
# kubectl get events -A --field-selector source=karpenter -w