{
  description = "HFT DeFy Challenge - NixOS Configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs = {
    nixpkgs,
    disko,
    nixos-facter-modules,
    ...
  }: {
    nixosConfigurations = {
      server1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./server1/configuration.nix
            ./common/base.nix
            ./common/tunnels.nix
            {
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCQyMU1puQduxR17dyVjLEA8PlUT8yhe7WyauG8EERSviQJAnPKT9fER+FCrDK9/63xmFPDXaNU/V4W7Qm91SkAaaYE9sbi9+M00pU4pgNvuIsNe/iRgqWFsEWLJwLOzD67rCy/XriqtZbVUXhE36UlCsLYaADOUjzvjT4XX9ktkvSyjA/bCs2qUPlc+j76tioTn0b9aZaMcJ0AgpBGXDQKcoNAXyMX3mlJq7ARHaDNLSak2ZM0mKa5XREYp0XukD8Eb9Kuf+0k7gCVmkuJU+fkzH6F+/DoMZYMrc9s9Fzn9+HBEVQhGv7nDLS2e+LGVmTTtMJDyc8SMYBpe42Bupo5AqzMbG3ifL6xFbvnyb5ZN/91vlBNR3K2HXziqBWwPSgyJs8ExVp/yfNRUvEd4SDRv6E8ff8KJWIe5e/8qeYddpfFN2G5qjbGlTvCDhYijn+ckn71p+7YQI0gifQafiAb2X3z970+vXRPeJnKC9s+N+s1xnO/Xwqxo/LN2xGGIBaysXpT8lJyXiJvohkrpQD0hlvcfYnvfF3RZzkEdzqKJi2ISA7N+Wqz+jjGsqE60VP5cGgtkoHm04ayCVrIwiNEWGQ90mI6D8Wph3cRhPDZcNjH1qQF6Swj+/K499hk2pCWP3rxfsfnErGsKxf2brqpfx5TM9T9k8ATuWnqkAwCXw== rustamgk@zbook-fury-g8"
              ];
              
              # Enable SSH
              services.openssh = {
                enable = true;
                settings.PermitRootLogin = "yes";
              };
              
              # Set hostname
              networking.hostName = "server1";
            }
          ];
        };
        
      server1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./server2/configuration.nix
            ./common/base.nix
            ./common/tunnels.nix
            {
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCQyMU1puQduxR17dyVjLEA8PlUT8yhe7WyauG8EERSviQJAnPKT9fER+FCrDK9/63xmFPDXaNU/V4W7Qm91SkAaaYE9sbi9+M00pU4pgNvuIsNe/iRgqWFsEWLJwLOzD67rCy/XriqtZbVUXhE36UlCsLYaADOUjzvjT4XX9ktkvSyjA/bCs2qUPlc+j76tioTn0b9aZaMcJ0AgpBGXDQKcoNAXyMX3mlJq7ARHaDNLSak2ZM0mKa5XREYp0XukD8Eb9Kuf+0k7gCVmkuJU+fkzH6F+/DoMZYMrc9s9Fzn9+HBEVQhGv7nDLS2e+LGVmTTtMJDyc8SMYBpe42Bupo5AqzMbG3ifL6xFbvnyb5ZN/91vlBNR3K2HXziqBWwPSgyJs8ExVp/yfNRUvEd4SDRv6E8ff8KJWIe5e/8qeYddpfFN2G5qjbGlTvCDhYijn+ckn71p+7YQI0gifQafiAb2X3z970+vXRPeJnKC9s+N+s1xnO/Xwqxo/LN2xGGIBaysXpT8lJyXiJvohkrpQD0hlvcfYnvfF3RZzkEdzqKJi2ISA7N+Wqz+jjGsqE60VP5cGgtkoHm04ayCVrIwiNEWGQ90mI6D8Wph3cRhPDZcNjH1qQF6Swj+/K499hk2pCWP3rxfsfnErGsKxf2brqpfx5TM9T9k8ATuWnqkAwCXw== rustamgk@zbook-fury-g8"
              ];
              
              # Enable SSH
              services.openssh = {
                enable = true;
                settings.PermitRootLogin = "yes";
              };
              
              # Set hostname
              networking.hostName = "server2";
            }
          ];
        };
    };
  };
}