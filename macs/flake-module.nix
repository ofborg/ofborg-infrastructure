{ inputs, ... }:
{
  flake.darwinConfigurations = inputs.nixpkgs.lib.listToAttrs (
    map
      (cfg: {
        name = cfg.hostname;
        value = inputs.darwin.lib.darwinSystem {
          system = "${cfg.system}-darwin";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./ofborg-common.nix
            ./profiles/${cfg.profile or cfg.system}.nix
            "${inputs.sops-nix}/modules/nix-darwin"
            { networking.hostName = cfg.hostname; }
          ];
        };
      })
      [
        {
          hostname = "nixos-foundation-macstadium-44911305";
          system = "x86_64";
          ip = "208.83.1.173";
          # 12 CPU cores
          # 32 GB RAM
          # 500 GB disk
        }
        {
          hostname = "nixos-foundation-macstadium-44911362";
          system = "x86_64";
          ip = "208.83.1.175";
          # 12 CPU cores
          # 32 GB RAM
          # 500 GB disk
        }
        {
          hostname = "nixos-foundation-macstadium-44911507";
          system = "x86_64";
          ip = "208.83.1.186";
          # 12 CPU cores
          # 32 GB RAM
          # 500 GB disk
        }
        {
          hostname = "nixos-foundation-macstadium-44911207";
          system = "aarch64";
          profile = "m1";
          ip = "208.83.1.145";
          # 8 CPU cores
          # 16 GB RAM
          # 256 GB disk
        }
        {
          hostname = "nixos-foundation-macstadium-44911104";
          system = "aarch64";
          profile = "m1";
          ip = "208.83.1.181";
          # 8 CPU cores
          # 16 GB RAM
          # 256 GB disk
        }
      ]
  );
}
