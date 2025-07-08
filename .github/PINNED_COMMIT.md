# Pinned Commit Documentation

## Current Status
The dev container build is currently pinned to commit `ba46c2d872bcb8b8dfb9ea3b31bfd4c92f1021f2` from the radius-project/radius repository.

## Reason for Pinning
This pinning was implemented to work around build failures caused by breaking changes in the gnostic-models dependency version 0.7.0. The issue was introduced in commit `78881f131f296d0d17ae3eaea5c522046bf7506b` (a dependency update on July 3, 2025).

## Related Issues
- [radius-project/radius#9948](https://github.com/radius-project/radius/issues/9948) - gnostic-models v0.7.0 breaking changes causing build failures

## How to Check if the Issue is Resolved

1. Monitor the original issue for updates: https://github.com/radius-project/radius/issues/9948
2. Periodically test building from the latest main branch:
   ```bash
   # Test if main branch builds successfully
   git clone https://github.com/radius-project/radius.git
   cd radius
   # Try building the dev container
   devcontainer build .
   ```
3. Look for commits that fix the gnostic-models compatibility issue

## How to Update When Fixed

When the upstream issue is resolved:

1. Update `.github/workflows/build-radius-devcontainer.yml`:
   - Change `ref: ba46c2d872bcb8b8dfb9ea3b31bfd4c92f1021f2` back to `ref: main`
   - Remove the `commit-ba46c2d8` image tag
   - Update comments to reflect the change

2. Update documentation:
   - Remove pinning references from `README.md`
   - Update `.github/workflows/README.md`

3. Test the new build thoroughly before merging

## Testing the Current Setup

To verify the current pinned setup works:
1. Trigger the workflow manually via GitHub Actions
2. Wait for the build to complete
3. Test the resulting dev container image

## Commit Details

**Pinned Commit**: ba46c2d872bcb8b8dfb9ea3b31bfd4c92f1021f2
**Date**: July 3, 2025 at 16:40:36Z
**Author**: Nithya Subramanian
**Message**: "modify udt2udt test to remove unneccessary dependency on configmap (#9923)"
**Status**: This was a stable commit before the problematic dependency update