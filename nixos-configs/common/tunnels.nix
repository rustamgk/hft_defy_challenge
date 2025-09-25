# Network tunnel configurations for performance testing
# This module sets up IPIP, GRE, and Wireguard tunnels between servers

{ config, pkgs, lib, ... }:

let
  # Server IP addresses (private network)
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
    ipip = if isServer1 then "192.168.1.1/24" else "192.168.1.2/24";
    gre = if isServer1 then "192.168.2.1/24" else "192.168.2.2/24";
    wireguard = if isServer1 then "192.168.3.1/24" else "192.168.3.2/24";
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
  # Systemd-networkd configuration for tunnels
  systemd.network = {
    enable = true;
    
    # IPIP Tunnel Configuration
    netdevs."ipip-tunnel" = {
      netdevConfig = {
        Kind = "ipip";
        Name = "ipip0";
      };
      tunnelConfig = {
        Local = if isServer1 then server1_ip else server2_ip;
        Remote = remote_server_ip;
        TTL = 64;
      };
    };
    
    networks."ipip-tunnel" = {
      matchConfig.Name = "ipip0";
      networkConfig = {
        Address = tunnel_ips.ipip;
        IPForward = true;
      };
      routeConfig = [
        {
          Destination = "${remote_ips.ipip}/32";
          Gateway = remote_ips.ipip;
        }
      ];
    };
    
    # GRE Tunnel Configuration  
    netdevs."gre-tunnel" = {
      netdevConfig = {
        Kind = "gre";
        Name = "gre0";
      };
      tunnelConfig = {
        Local = if isServer1 then server1_ip else server2_ip;
        Remote = remote_server_ip;
        TTL = 64;
      };
    };
    
    networks."gre-tunnel" = {
      matchConfig.Name = "gre0";
      networkConfig = {
        Address = tunnel_ips.gre;
        IPForward = true;
      };
      routeConfig = [
        {
          Destination = "${remote_ips.gre}/32";
          Gateway = remote_ips.gre;
        }
      ];
    };
  };
  
  # Wireguard configuration (using NixOS wireguard module)
  networking.wireguard.interfaces.wg0 = {
    ips = [ tunnel_ips.wireguard ];
    listenPort = 51820;
    
    # Private key will be generated per-server
    privateKeyFile = "/etc/wireguard/private.key";
    
    peers = [
      {
        # Peer configuration (other server)
        # Public key will be set per-server in specific configs
        publicKey = ""; # Will be overridden in server-specific configs
        allowedIPs = [ "${remote_ips.wireguard}/32" ];
        endpoint = "${remote_server_ip}:51820";
        persistentKeepalive = 25;
      }
    ];
  };
  
  # Additional routing for tunnel forwarding (server1 only)
  systemd.network.networks."tunnel-forwarding" = lib.mkIf isServer1 {
    matchConfig.Name = "gre0";
    routeConfig = [
      # Route to Wireguard network via GRE tunnel for forwarding testing
      {
        Destination = wireguard_network;
        Gateway = remote_ips.gre;
      }
    ];
  };
  
  # Ensure tunnel interfaces are brought up
  systemd.services."setup-tunnel-interfaces" = {
    description = "Setup tunnel interfaces";
    after = [ "network.target" "systemd-networkd.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      # Wait for network to be ready
      sleep 5
      
      # Ensure tunnel interfaces are up
      ${pkgs.iproute2}/bin/ip link set ipip0 up || true
      ${pkgs.iproute2}/bin/ip link set gre0 up || true
      ${pkgs.iproute2}/bin/ip link set wg0 up || true
      
      # Add routes if they don't exist
      ${pkgs.iproute2}/bin/ip route add ${remote_ips.ipip}/32 dev ipip0 || true
      ${pkgs.iproute2}/bin/ip route add ${remote_ips.gre}/32 dev gre0 || true
      ${pkgs.iproute2}/bin/ip route add ${remote_ips.wireguard}/32 dev wg0 || true
      
      echo "Tunnel interfaces configured"
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
        echo "Generated Wireguard keys"
      fi
    '';
  };
}