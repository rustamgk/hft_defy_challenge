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
            ./server1/hardware-configuration.nix
            ./server1/disko.nix
            ./server1/configuration.nix
            ./common/base.nix
            ./common/tunnels.nix
            {
              # Set hostname
              networking.hostName = "server1";
            }
          ];
        };
        
      server2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./server2/hardware-configuration.nix
            ./server2/disko.nix
            ./server2/configuration.nix
            ./common/base.nix
            ./common/tunnels.nix
            {
              # Set hostname
              networking.hostName = "server2";
            }
          ];
        };
    };
  };
}