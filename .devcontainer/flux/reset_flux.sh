#!/bin/bash

# Description: Removes the flux files from the remote repo, deletes the local files, and deletes the local k3d cluster.
# Usage: ./reset_flux.sh <repository name>

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

k3d cluster delete
rm -rf ./.notes/$repo_name/clusters/
git -C ./.notes/$repo_name/ add -A
git -C ./.notes/$repo_name/ commit -m "reset $(git rev-parse --short HEAD)"
git -C ./.notes/$repo_name/ push
rm -rf ./.notes/$repo_name/
