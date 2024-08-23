#!/bin/bash

# Authenticates to GitHub using the GitHub CLI and sets up the user name and email address in git.

# The script will prompt you for two interactive authentication events with GitHub: the first sets the user
# scope to allow reading user account data, and the second sets the default scope, which is more restrictive.

gh auth login --hostname github.com --scopes user --web

gh_acct_name=$(gh api user --jq '.name')
if [ -z "$gh_acct_name" ]; then
    echo "Error: gh_email is null"
    exit 1
fi

gh_email=$(gh api user/emails --jq '.[] | select(.email | endswith("noreply.github.com")) | .email')
if [ -z "$gh_email" ]; then
    echo "Error: gh_email is null"
    exit 1
fi

git config --global user.name "$gh_acct_name"
git config --global user.email "$gh_email"
git config --global init.defaultBranch main

# Downgrade to the default GH scope
gh auth refresh --hostname github.com --web

# Use Windows credential manager with git. See https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-git
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
git config --global credential.https://dev.azure.com.useHttpPath true

echo "Git has been configured with the following settings:"
echo " - user.email: $(git config --global user.email)"
echo " - user.name: $(git config --global user.email)"
