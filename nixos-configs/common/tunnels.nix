# Network tunnel configurations for performance testing
# This module sets up IPIP, GRE, and Wireguard tunnels between servers

{ config, pkgs, lib, ... }:

let
  # Server IP addresses (private network for lower latency)
  server1_ip = "10.0.0.10";
  server2_ip = "10.0.0.20";
  
  # Tunnel network ranges
  ipip_network = "192.168.1.0/24";
  gre_network = "192.168.2.0/24";
  wireguard_network = "192.168.3.0/24";
  
  # Helper function to determine if this is server1 or server2
  isServer1 = config.networking.hostName == "server1";
  isServer2 = config.networking.hostName == "server2";
  
  # IP assignments based on server
  tunnel_ips = {
    ipip = if isServer1 then "192.168.1.1" else "192.168.1.2";
    gre = if isServer1 then "192.168.2.1" else "192.168.2.2";
    wireguard = if isServer1 then "192.168.3.1" else "192.168.3.2";
  };
  
  # Remote tunnel IPs for routing
  remote_ips = {
    ipip = if isServer1 then "192.168.1.2" else "192.168.1.1";
    gre = if isServer1 then "192.168.2.2" else "192.168.2.1";
    wireguard = if isServer1 then "192.168.3.2" else "192.168.3.1";
  };
  
  # Remote server IP
  remote_server_ip = if isServer1 then server2_ip else server1_ip;

in {
  # Wireguard configuration (using NixOS wireguard module)
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${tunnel_ips.wireguard}/24" ];
    listenPort = 51820;
    
    # Private key will be generated per-server
    privateKeyFile = "/etc/wireguard/private.key";
    
    peers = [
      {
        # Peer configuration will be set in server-specific configs
        publicKey = "PLACEHOLDER_PUBLIC_KEY";
        allowedIPs = [ "192.168.3.0/24" ];
        endpoint = "${remote_server_ip}:51820";
        persistentKeepalive = 25;
      }
    ];
  };
  
  # Create tunnel interfaces using systemd services (simpler than systemd-networkd)
  systemd.services."setup-tunnel-interfaces" = {
    description = "Setup tunnel interfaces";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      # Wait for network to be ready
      sleep 10
      
      echo "Setting up tunnel interfaces..."
      
      # Create IPIP tunnel
      ${pkgs.iproute2}/bin/ip tunnel add ipip0 mode ipip \
        remote ${remote_server_ip} \
        local ${if isServer1 then server1_ip else server2_ip} \
        ttl 64 || true
      
      ${pkgs.iproute2}/bin/ip addr add ${tunnel_ips.ipip}/24 dev ipip0 || true
      ${pkgs.iproute2}/bin/ip link set ipip0 up || true
      
      # Create GRE tunnel  
      ${pkgs.iproute2}/bin/ip tunnel add gre0 mode gre \
        remote ${remote_server_ip} \
        local ${if isServer1 then server1_ip else server2_ip} \
        ttl 64 || true
        
      ${pkgs.iproute2}/bin/ip addr add ${tunnel_ips.gre}/24 dev gre0 || true
      ${pkgs.iproute2}/bin/ip link set gre0 up || true
      
      echo "Tunnel interfaces configured:"
      ${pkgs.iproute2}/bin/ip addr show ipip0 || true
      ${pkgs.iproute2}/bin/ip addr show gre0 || true
      ${pkgs.iproute2}/bin/ip addr show wg0 || true
    '';
    
    preStop = ''
      # Cleanup tunnels on stop
      ${pkgs.iproute2}/bin/ip link delete ipip0 || true
      ${pkgs.iproute2}/bin/ip link delete gre0 || true
    '';
  };
  
  # Create Wireguard key generation service
  systemd.services."wireguard-key-gen" = {
    description = "Generate Wireguard keys";
    before = [ "wireguard-wg0.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      if [ ! -f /etc/wireguard/private.key ]; then
        mkdir -p /etc/wireguard
        ${pkgs.wireguard-tools}/bin/wg genkey > /etc/wireguard/private.key
        chmod 600 /etc/wireguard/private.key
        ${pkgs.wireguard-tools}/bin/wg pubkey < /etc/wireguard/private.key > /etc/wireguard/public.key
        chmod 644 /etc/wireguard/public.key
        echo "Generated Wireguard keys for $(hostname)"
        echo "Public key: $(cat /etc/wireguard/public.key)"
      fi
    '';
  };
  
  # Performance testing service
  systemd.services."tunnel-performance-test" = {
    description = "Tunnel Performance Test Helper";
    after = [ "setup-tunnel-interfaces.service" "wireguard-wg0.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      echo "Tunnel Performance Test Environment Ready"
      echo "========================================="
      echo "IPIP Tunnel: ${tunnel_ips.ipip}/24"
      echo "GRE Tunnel:  ${tunnel_ips.gre}/24"
      echo "WG Tunnel:   ${tunnel_ips.wireguard}/24"
      echo ""
      echo "Test commands:"
      echo "# Test IPIP latency:"
      echo "ping -c 10 ${if isServer1 then "192.168.1.2" else "192.168.1.1"}"
      echo "# Test GRE latency:"  
      echo "ping -c 10 ${if isServer1 then "192.168.2.2" else "192.168.2.1"}"
      echo "# Test Wireguard latency:"
      echo "ping -c 10 ${if isServer1 then "192.168.3.2" else "192.168.3.1"}"
      echo ""
      echo "# Run iperf3 server (on one machine):"
      echo "iperf3 -s -B ${tunnel_ips.ipip}"
      echo "# Run iperf3 client (on other machine):"
      echo "iperf3 -c ${if isServer1 then "192.168.1.2" else "192.168.1.1"} -t 60"
    '';
  };
}