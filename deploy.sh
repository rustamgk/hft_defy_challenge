#!/bin/bash

# Direct nixos-anywhere deecho ""
echo "📡 Deploying to Server1 (forwarding node)..."
nix run github:nix-community/nixos-anywhere -- --flake ./nixos-configs#server1 --target-host root@$SERVER1_IP

echo ""
echo "📡 Deploying to Server2 (testing node)..." 
nix run github:nix-community/nixos-anywhere -- --flake ./nixos-configs#server2 --target-host root@$SERVER2_IPt to existing Hetzner servers
# Usage: ./deploy.sh

set -e

echo "🚀 HFT DeFy Challenge - Direct NixOS Deployment"
echo "==============================================="

# Known server IPs
SERVER1_IP="91.98.144.4"  # Forwarding node
SERVER2_IP="91.98.95.57"  # Testing node

# Test SSH connectivity
echo ""
echo "testing SSH connectivity to existing servers..."
if ssh -i ~/.ssh/hft_defy -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SERVER1_IP "echo 'SSH test successful'" 2>/dev/null; then
    echo "   Server1 ($SERVER1_IP): SSH connection successful"
else
    echo "   Server1 ($SERVER1_IP): SSH connection failed"
    echo "   Please ensure:"
    echo "   - Server is running and accessible"
    echo "   - SSH key is authorized on the server"
    echo "   - Firewall allows SSH (port 22)"
    exit 1
fi

if ssh -i ~/.ssh/hft_defy -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SERVER2_IP "echo 'SSH test successful'" 2>/dev/null; then
    echo "Server2 ($SERVER2_IP): SSH connection successful"
else
    echo "Server2 ($SERVER2_IP): SSH connection failed"
    exit 1
fi

# Deploy NixOS to both servers
echo ""
echo "🚀 Starting NixOS deployment..."

echo ""
echo "📡 Deploying to Server1 (forwarding node)..."
nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/nixos-anywhere -- --flake ./nixos-configs#server1 --target-host root@91.98.144.4 -i ~/.ssh/hft_defy

echo ""
echo "📡 Deploying to Server2 (testing node)..." 
nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/nixos-anywhere -- --flake ./nixos-configs#server2 --target-host root@91.98.95.57 -i ~/.ssh/hft_defy

echo " Test tunnel connectivity:"
echo " ssh -i ~/.ssh/hft_defy root@$SERVER2_IP 'ping -c 3 192.168.1.1'"
