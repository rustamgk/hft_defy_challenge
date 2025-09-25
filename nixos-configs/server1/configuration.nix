# NixOS Configuration for Server1 (Forwarding Node)
# This server will handle traffic forwarding between tunnels

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
  networking.hostName = "server1";
  networking.hostId = "12345678";
  
  # Private network interface configuration (use DHCP to get Hetzner-assigned IP)
  networking.interfaces.enp7s0.useDHCP = true;

  # Using traditional networking - DHCP will be handled automatically

  # Private network interface configuration (commented out for initial setup)
  # systemd.network.networks."ens10" = {
  #   matchConfig.Name = "ens10";  # Hetzner private network interface
  #   networkConfig = {
  #     Address = "10.0.0.10/24";
  #   };
  # };

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

  # Advanced firewall rules for forwarding (moved to base.nix to avoid conflicts)

  # Wireguard peer configuration (disabled for initial setup)
  # networking.wireguard.interfaces.wg0.peers = [
  #   {
  #     # Server2's public key (will be set after key generation)
  #     publicKey = "PLACEHOLDER_SERVER2_PUBLIC_KEY";
  #     allowedIPs = [ "192.168.3.2/32" ];
  #     endpoint = "10.0.0.20:51820";
  #     persistentKeepalive = 25;
  #   }
  # ];

  # Service for tunnel forwarding setup (disabled for initial setup)
  # systemd.services."tunnel-forwarding-setup" = {
  #   description = "Configure tunnel forwarding routes";
  #   after = [ "network.target" "setup-tunnel-interfaces.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };
  #   
  #   script = ''
  #     # Wait for all tunnel interfaces to be ready
  #     sleep 10
  #     
  #     # Set up forwarding routes between tunnels
  #     echo "Setting up tunnel forwarding routes..."
  #     
  #     # Route GRE traffic to Wireguard
  #     ${pkgs.iproute2}/bin/ip route add 192.168.3.0/24 via 192.168.2.2 dev gre0 || true
  #     
  #     # Route IPIP traffic to Wireguard  
  #     ${pkgs.iproute2}/bin/ip route add 192.168.3.0/24 via 192.168.1.2 dev ipip0 || true
  #     
  #     # Cross-tunnel routes for comprehensive testing
  #     ${pkgs.iproute2}/bin/ip route add 192.168.1.0/24 via 192.168.2.2 dev gre0 || true
  #     ${pkgs.iproute2}/bin/ip route add 192.168.2.0/24 via 192.168.1.2 dev ipip0 || true
  #     
  #     echo "Tunnel forwarding routes configured"
  #     
  #     # Display routing table for verification
  #     echo "Current routing table:"
  #     ${pkgs.iproute2}/bin/ip route show
  #   '';
  # };



  # SSH keys are configured in base.nix - no need to duplicate here

}