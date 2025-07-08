# GitHub Workflows

This directory contains GitHub Actions workflows for automating tasks related to Radius development.

## build-radius-devcontainer.yml

This workflow builds and publishes the Radius development container from the [radius-project/radius](https://github.com/radius-project/radius) repository.

### Schedule
- Runs weekly on Sundays at 2 AM UTC
- Can be triggered manually via workflow_dispatch

### What it does
1. Checks out the radius-project/radius repository (pinned to a specific commit to avoid build issues)
2. Builds the dev container using the devcontainer CLI
3. Publishes the container image to GitHub Container Registry (ghcr.io)

### Commit Pinning
The workflow is currently pinned to commit `ba46c2d872bcb8b8dfb9ea3b31bfd4c92f1021f2` to avoid build issues caused by breaking changes in dependencies (specifically gnostic-models v0.7.0). This commit is from before the problematic dependency update on July 3, 2025.

### Container Registry
The built container is published to:
- `ghcr.io/[owner]/radius-dev:latest`
- `ghcr.io/[owner]/radius-dev:[run_number]`
- `ghcr.io/[owner]/radius-dev:weekly-[run_number]`

### Permissions
The workflow uses the `GITHUB_TOKEN` with the following permissions:
- `contents: read` - to check out the repository
- `packages: write` - to publish to GitHub Container Registry