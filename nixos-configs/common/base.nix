# This module contains shared settings for both test servers in Hetzner

{ config, pkgs, lib, ... }:

{
  # Import hardware configuration (will be generated per-server)
  imports = [ ];

  # Use traditional networking (more reliable for Hetzner Cloud)
  networking.useNetworkd = false;
  networking.useDHCP = true;
  
  # Disable NetworkManager
  networking.networkmanager.enable = false;

  # Boot configuration
  boot = {
    # Bootloader configuration is handled per-server
    
    # Kernel modules needed for tunneling
    kernelModules = [
      "ipip"      # IPIP tunnel support
      "gre"       # GRE tunnel support
      "wireguard" # Wireguard support
    ];
    
    # Kernel parameters for network performance and tunneling
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

  # SSH keys for root user
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCQyMU1puQduxR17dyVjLEA8PlUT8yhe7WyauG8EERSviQJAnPKT9fER+FCrDK9/63xmFPDXaNU/V4W7Qm91SkAaaYE9sbi9+M00pU4pgNvuIsNe/iRgqWFsEWLJwLOzD67rCy/XriqtZbVUXhE36UlCsLYaADOUjzvjT4XX9ktkvSyjA/bCs2qUPlc+j76tioTn0b9aZaMcJ0AgpBGXDQKcoNAXyMX3mlJq7ARHaDNLSak2ZM0mKa5XREYp0XukD8Eb9Kuf+0k7gCVmkuJU+fkzH6F+/DoMZYMrc9s9Fzn9+HBEVQhGv7nDLS2e+LGVmTTtMJDyc8SMYBpe42Bupo5AqzMbG3ifL6xFbvnyb5ZN/91vlBNR3K2HXziqBWwPSgyJs8ExVp/yfNRUvEd4SDRv6E8ff8KJWIe5e/8qeYddpfFN2G5qjbGlTvCDhYijn+ckn71p+7YQI0gifQafiAb2X3z970+vXRPeJnKC9s+N+s1xnO/Xwqxo/LN2xGGIBaysXpT8lJyXiJvohkrpQD0hlvcfYnvfF3RZzkEdzqKJi2ISA7N+Wqz+jjGsqE60VP5cGgtkoHm04ayCVrIwiNEWGQ90mI6D8Wph3cRhPDZcNjH1qQF6Swj+/K499hk2pCWP3rxfsfnErGsKxf2brqpfx5TM9T9k8ATuWnqkAwCXw== rustamgk@zbook-fury-g8"
  ];

  # Firewall configuration - allow tunnel protocols for performance testing
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      5201  # iperf3
      5001  # iperf2
      12865 # netperf
    ];
    allowedUDPPorts = [
      51820  # Wireguard
    ];
    
    # Allow tunnel protocols for performance testing
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