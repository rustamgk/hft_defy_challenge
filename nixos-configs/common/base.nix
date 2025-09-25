# This module contains shared settings for both test servers in Hetzner

{ config, pkgs, lib, ... }:

{
  # Import hardware configuration (will be generated per-server)
  imports = [ ];

  # Use systemd-networkd for consistent network management
  networking.useNetworkd = true;
  systemd.network.enable = true;
  
  # Disable NetworkManager as it conflicts with systemd-networkd
  networking.networkmanager.enable = false;
  
  # Enable systemd-resolved for DNS
  services.resolved.enable = true;

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    # Kernel modules needed for tunneling
    kernelModules = [
      "ipip"      # IPIP tunnel support
      "gre"       # GRE tunnel support
      "wireguard" # Wireguard support
    ];
    
    # Kernel parameters for network performance
    kernel.sysctl = {
      # Enable IP forwarding (needed for tunnel forwarding)
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      
      # Network performance tuning
      "net.core.rmem_max" = 134217728;      # 128MB
      "net.core.wmem_max" = 134217728;      # 128MB
      "net.ipv4.tcp_rmem" = "4096 65536 134217728";
      "net.ipv4.tcp_wmem" = "4096 65536 134217728";
      "net.core.netdev_max_backlog" = 5000;
      
      # Reduce TIME_WAIT
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 30;
      
      # Enable TCP congestion control algorithms
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  # Essential packages for network testing and stuff
  environment.systemPackages = with pkgs; [
    # Network testing tools
    iperf3
    iperf2
    netperf
    nuttcp
    iproute2
    tcpdump
    wireshark-cli
    mtr
    traceroute
    nmap
    socat
    htop
    iotop
    nethogs
    iftop
    git
    vim
    tmux
    curl
    wget
    jq
    sysstat
    perf-tools
    wireguard-tools
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
    };
    openFirewall = true;
  };

  # Firewall configuration - allow tunnel protocols
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      5201  # iperf3
      5001  # iperf2
      12865 # netperf
    ];
    allowedUDPPorts = [
      51820
    ];
    
    # Allow IPIP and GRE protocols
    extraCommands = ''
      # Allow IPIP protocol (protocol 4)
      iptables -A INPUT -p ipencap -j ACCEPT
      iptables -A OUTPUT -p ipencap -j ACCEPT
      
      # Allow GRE protocol (protocol 47)  
      iptables -A INPUT -p gre -j ACCEPT
      iptables -A OUTPUT -p gre -j ACCEPT
      
      # Allow all traffic between tunnel interfaces
      iptables -A INPUT -i ipip+ -j ACCEPT
      iptables -A INPUT -i gre+ -j ACCEPT
      iptables -A INPUT -i wg+ -j ACCEPT
    '';
  };

  # Time synchronization
  services.chrony.enable = true;

  # Create test user for running performance tests
  users.users.testuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keyFiles = [ ];  # Will be set per-server
  };

  # Disable sleep and hibernation for consistent testing
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # System information
  system.stateVersion = "25.05";
}