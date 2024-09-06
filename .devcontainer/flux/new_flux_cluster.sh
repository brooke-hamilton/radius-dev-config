#!/bin/bash
set -e

k3d cluster delete
k3d cluster create
flux install
