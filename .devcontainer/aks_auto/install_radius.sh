#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <resource group name>"
    exit 1
fi

resource_group=$1
aks_cluster=$(kubectl config current-context)

echo "Installing Radius on cluster $aks_cluster in resource group $resource_group"
rad install kubernetes
rad workspace create kubernetes "$cluster_name"
rad group create "$aks_cluster"
rad group switch "$aks_cluster"
rad env create "$aks_cluster" --namespace default
rad env switch "$aks_cluster"

# kubectl get nodes && kubectl get namespaces && kubectl get pods -n radius-system
# kubectl get events -A --field-selector source=karpenter -w