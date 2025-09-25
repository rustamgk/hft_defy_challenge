# NixOS Configuration for Server1 (Forwarding Node)
# This server will handle traffic forwarding between tunnels

{ config, pkgs, lib, ... }:

{
  imports = [
    # Common configurations are imported via flake.nix
  ];

  # Hostname and networking
  networking.hostName = "server1";
  networking.hostId = "12345678";  # Required for some network features

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
    
  ## TODO

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