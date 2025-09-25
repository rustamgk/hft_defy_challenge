# NixOS Configuration   # Using traditional networking - DHCP will be handled automaticallyng Node)
# This server will be used for performance measurements

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../common/base.nix
    ../common/tunnels.nix  # Re-enabled for tunnel performance testing
    # Common configurations are imported via flake.nix
  ];

  # Boot loader configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  # Hostname and networking
  networking.hostName = "server2";
  networking.hostId = "87654321";
  
  # Private network interface configuration (Hetzner private network)  
  networking.interfaces.ens10 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "10.0.0.20";
      prefixLength = 24;
    }];
  }; 

  # Use traditional networking (systemd-networkd disabled in base.nix)
  # Main interface will get DHCP automatically

  # Private network interface configuration (commented out for initial setup)
  # systemd.network.networks."ens10" = {
  #   matchConfig.Name = "ens10";  # Hetzner private network interface
  #   networkConfig = {
  #     Address = "10.0.0.20/24";
  #   };
  # };

  # Wireguard peer configuration (disabled for initial setup)
  # networking.wireguard.interfaces.wg0.peers = [
  #   {
  #     # Server1's public key (will be set after key generation)
  #     publicKey = "PLACEHOLDER_SERVER1_PUBLIC_KEY";
  #     allowedIPs = [ "192.168.3.1/32" ];
  #     endpoint = "10.0.0.10:51820";
  #     persistentKeepalive = 25;
  #   }
  # ];



  # SSH keys are configured in base.nix - no need to duplicate here

}