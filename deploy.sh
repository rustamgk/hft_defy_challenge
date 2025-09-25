#!/bin/bash

# Direct nixos-anywhere deployment to existing Hetzner servers in DE region
# Usage: ./deploy.sh
set -e

echo "HFT DEFY Challenge - Direct NixOS Deployment"
echo "==============================================="

# Known server IPs
SERVER1_IP=""  # Forwarding node
SERVER2_IP=""  # Testing node

# Deploy NixOS to both servers
echo ""
echo "starting NixOS deployment..."

echo ""
echo "Deploying to Server1 (forwarding node)..."
nixos-anywhere --flake .#server1 root@$SERVER1_IP

echo ""
echo "Deploying to Server2 (testing node)..." 
nixos-anywhere --flake .#server2 root@$SERVER2_IP