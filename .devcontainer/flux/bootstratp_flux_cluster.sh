#!/bin/bash
set -e

# Description: Bootstraps a new GitHub repository with Flux and deploys the podinfo app.
# The script follows the steps at https://fluxcd.io/flux/get-started/
# Usage: ./bootstrap_flux_cluster.sh <repository name>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <repository name>"
    exit 1
fi

repo_name=$1

# Validate script is being run from its own folder
if [ "$(dirname "$0")" != "." ]; then
    echo "Please run the script from its own folder."
    exit 1
fi

# Check if logged into GitHub CLI
if ! gh auth status >/dev/null 2>&1; then
    echo "Please log into GitHub CLI using 'gh auth login'"
    exit 1
fi

export GITHUB_USER=$(gh api user | jq -r .login)
export GITHUB_TOKEN=$(gh auth token)

flux check --pre

# Add flux system files to the repo.
flux bootstrap github \
  --token-auth \
  --owner=$GITHUB_USER \
  --repository=$repo_name \
  --branch=main \
  --path=clusters/my-cluster \
  --personal

# Create a folder for the repo to be used by flux.
if [ ! -d ".notes" ]; then
    mkdir .notes
fi
cd .notes

# Clone the repo (remove the repo first if it already exists).
if [ -d "$repo_name" ]; then
    echo "Repo already exists. Start with an empty repo."
    exit 1
else
    echo "Cloning $repo_name repo."
    git clone https://github.com/$GITHUB_USER/$repo_name
fi

cd $repo_name

echo "Adding podinfo app to the repo at ./clusters/my-cluster/podinfo-source.yaml"
flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=1m \
  --export > ./clusters/my-cluster/podinfo-source.yaml

git add -A && git commit -m "Add podinfo GitRepository"
git push

# Create a kustomization that deploys the podinfo app.
flux create kustomization podinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/podinfo-kustomization.yaml

git add -A && git commit -m "Add podinfo Kustomization"
git push

flux get kustomizations -w
