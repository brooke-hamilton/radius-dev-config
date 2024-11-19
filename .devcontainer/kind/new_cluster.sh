#!/bin/bash

# See Radius docs at https://docs.radapp.io/guides/operations/kubernetes/overview/#supported-kubernetes-clusters
kind delete cluster
kind create cluster --config "$(dirname "$0")/kind-config.yaml"
rad install kubernetes --set rp.publicEndpointOverride=localhost:8080
