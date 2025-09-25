# NixOS Configuration for Server1 (Forwarding Node)
# This server will handle traffic forwarding between tunnels

{ config, pkgs, lib, ... }:

{
  imports = [
    # Common configurations are imported via flake.nix
  ];

  # Hostname and networking
  networking.hostName = "server1";
  networking.hostId = "12345678";

  # Primary network interface configuration
  systemd.network.networks."eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      DHCP = "yes";
      IPForward = true;
    };
    dhcpV4Config = {
      UseRoutes = true;
      UseDNS = true;
    };
  };

  # Private network interface configuration
  systemd.network.networks."ens10" = {
    matchConfig.Name = "ens10";  # Hetzner private network interface
    networkConfig = {
      Address = "10.0.0.10/24";
      IPForward = true;
    };
  };

  # Enhanced forwarding configuration for server1
  boot.kernel.sysctl = {
    # Enable forwarding between all interfaces
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.forwarding" = 1;
    
    # Enable proxy ARP for tunnel forwarding
    "net.ipv4.conf.all.proxy_arp" = 1;
    
    # Disable source route verification to allow tunnel forwarding
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
  };

  # Advanced firewall rules for forwarding
  networking.firewall = {
    enable = true;
    
    extraCommands = ''
      # Allow forwarding between tunnel interfaces
      iptables -A FORWARD -i gre0 -o wg0 -j ACCEPT
      iptables -A FORWARD -i wg0 -o gre0 -j ACCEPT
      iptables -A FORWARD -i ipip0 -o wg0 -j ACCEPT
      iptables -A FORWARD -i wg0 -o ipip0 -j ACCEPT
      iptables -A FORWARD -i ipip0 -o gre0 -j ACCEPT
      iptables -A FORWARD -i gre0 -o ipip0 -j ACCEPT
      
      # Enable NAT for tunnel traffic if needed
      iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o wg0 -j MASQUERADE
      iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o wg0 -j MASQUERADE
      iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o gre0 -j MASQUERADE
      
      # Allow all established and related connections
      iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
    '';
  };

  # Wireguard peer configuration for server1
  networking.wireguard.interfaces.wg0.peers = [
    {
      # Server2's public key (will be set after key generation)
      publicKey = "PLACEHOLDER_SERVER2_PUBLIC_KEY";
      allowedIPs = [ "192.168.3.2/32" ];
      endpoint = "10.0.0.20:51820";
      persistentKeepalive = 25;
    }
  ];

  # Service for tunnel forwarding setup
  systemd.services."tunnel-forwarding-setup" = {
    description = "Configure tunnel forwarding routes";
    after = [ "network.target" "setup-tunnel-interfaces.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      # Wait for all tunnel interfaces to be ready
      sleep 10
      
      # Set up forwarding routes between tunnels
      echo "Setting up tunnel forwarding routes..."
      
      # Route GRE traffic to Wireguard
      ${pkgs.iproute2}/bin/ip route add 192.168.3.0/24 via 192.168.2.2 dev gre0 || true
      
      # Route IPIP traffic to Wireguard  
      ${pkgs.iproute2}/bin/ip route add 192.168.3.0/24 via 192.168.1.2 dev ipip0 || true
      
      # Cross-tunnel routes for comprehensive testing
      ${pkgs.iproute2}/bin/ip route add 192.168.1.0/24 via 192.168.2.2 dev gre0 || true
      ${pkgs.iproute2}/bin/ip route add 192.168.2.0/24 via 192.168.1.2 dev ipip0 || true
      
      echo "Tunnel forwarding routes configured"
      
      # Display routing table for verification
      echo "Current routing table:"
      ${pkgs.iproute2}/bin/ip route show
    '';
  };

  # Performance monitoring specific to forwarding server
  systemd.services."forwarding-monitor" = {
    description = "Monitor tunnel forwarding performance";
    after = [ "tunnel-forwarding-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 30;
    };
    
    script = ''
      while true; do
        echo "$(date): Tunnel interface status" >> /var/log/tunnel-status.log
        ${pkgs.iproute2}/bin/ip addr show ipip0 >> /var/log/tunnel-status.log 2>&1 || true
        ${pkgs.iproute2}/bin/ip addr show gre0 >> /var/log/tunnel-status.log 2>&1 || true
        ${pkgs.iproute2}/bin/ip addr show wg0 >> /var/log/tunnel-status.log 2>&1 || true
        echo "---" >> /var/log/tunnel-status.log
        sleep 60
      done
    '';
  };

  # SSH keys for server1
  users.users.root.openssh.authorizedKeys.keyFiles = [ 
    # Will be populated with the SSH public key
  ];
  
  users.users.testuser.openssh.authorizedKeys.keyFiles = [
    # Will be populated with the SSH public key  
  ];

  # Additional packages for forwarding server
  environment.systemPackages = with pkgs; [
    tcpflow
    conntrack-tools
    bridge-utils
    ethtool
  ];
}