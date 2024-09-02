#!/bin/bash

k3d cluster delete

# See Radius docs at https://docs.radapp.io/guides/operations/kubernetes/overview/#supported-kubernetes-clusters
k3d cluster create -p "8081:80@loadbalancer" --k3s-arg "--disable=traefik@server:*" --k3s-arg "--disable=servicelb@server:*"
rad install kubernetes --set rp.publicEndpointOverride=localhost:8081
