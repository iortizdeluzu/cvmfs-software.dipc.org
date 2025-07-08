#!/bin/bash

set -e

echo "[*] Starting Stratum0 container..."

# Ensure stratum user exists
if ! id stratum &>/dev/null; then
    useradd -m stratum
fi

# Set up CVMFS if not already done
if [ ! -d /etc/cvmfs/keys ]; then
    echo "[*] Setting up CVMFS server..."
    cvmfs_server setup
fi

# Create repository if not exists
if [ ! -d /etc/cvmfs/repositories.d/software.dipc.org ]; then
    echo "[*] Creating repository software.dipc.org..."
    cvmfs_server mkfs -o stratum -w http://stratum0/cvmfs/software.dipc.org software.dipc.org
fi

# Populate repository if empty
if [ ! -f /cvmfs/software.dipc.org/README.txt ]; then
    echo "[*] Populating repository..."
    cvmfs_server transaction software.dipc.org
    echo "Hello from CVMFS inside Stratum0!" > /cvmfs/software.dipc.org/README.txt
    cvmfs_server publish software.dipc.org
fi

echo "[*] Repository ready:"
ls /cvmfs/software.dipc.org || true

# Keep container running
tail -f /dev/null

