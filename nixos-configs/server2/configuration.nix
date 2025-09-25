# NixOS Configuration for Server2 (Testing Node)
# This server will be used for performance measurements

{ config, pkgs, lib, ... }:

{
  imports = [
    # Common configurations are imported via flake.nix
  ];

  # Boot loader configuration
  boot.loader.grub.enable = true;

  # Hostname and networking
  networking.hostName = "server2";
  networking.hostId = "87654321"; 

  # Primary network interface configuration
  systemd.network.networks."eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      DHCP = "yes";
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
      Address = "10.0.0.20/24";
    };
  };

  # Wireguard peer configuration for server2
  networking.wireguard.interfaces.wg0.peers = [
    {
      # Server1's public key (will be set after key generation)
      publicKey = "PLACEHOLDER_SERVER1_PUBLIC_KEY";
      allowedIPs = [ "192.168.3.1/32" ];
      endpoint = "10.0.0.10:51820";
      persistentKeepalive = 25;
    }
  ];



  # SSH keys for server2
  users.users.root.openssh.authorizedKeys.keyFiles = [
    # Will be populated with the SSH public key
  ];
  
  users.users.testuser.openssh.authorizedKeys.keyFiles = [
    # Will be populated with the SSH public key
  ];


}