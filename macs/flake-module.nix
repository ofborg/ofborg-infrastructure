{ inputs, ... }:
{
  flake.darwinConfigurations = inputs.nixpkgs.lib.listToAttrs (
    map
      (cfg: {
        name = cfg.hostname;
        value = inputs.darwin.lib.darwinSystem {
          inherit (cfg) system;

          modules = [
            ./ofborg-common.nix
            ./profiles/${cfg.system}.nix
          ];
        };
      })
      [
        {
          hostname = "nixos-foundation-macstadium-44911305";
          system = "x86_64";
          # 12 CPU cores
          # 32 GB RAM
          # 500 GB disk
        }
      ]
  );
  # nixos-foundation-macstadium-44911305 root@208.83.1.173, x86_64,  12 cores, 32GB RAM, 500GB disk
  # nixos-foundation-macstadium-44911362 root@208.83.1.175, x86_64,  12 cores, 32GB RAM, 500GB disk
  # nixos-foundation-macstadium-44911507 root@208.83.1.186, x86_64,  12 cores, 32GB RAM, 500GB disk

  # nixos-foundation-macstadium-44911207 root@208.83.1.145, aarch64,  8 cores, 16GB RAM, 256GB disk
  # nixos-foundation-macstadium-44911104 root@208.83.1.181, aarch64,  8 cores, 16GB RAM, 256GB disk
}
