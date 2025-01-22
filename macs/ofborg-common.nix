{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ ./ofborg.nix ];

  environment.systemPackages = [
    config.nix.package
    pkgs.nix-top
  ];

  system.stateVersion = 5;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = false;
    };
    bash = {
      enable = true;
      completion.enable = true;
    };
  };

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-silent-time = 7200; # 2h
      timeout = 43200; # 12h
      min-free = 30 * 1024 * 1024 * 1024;
      max-free = 50 * 1024 * 1024 * 1024;
    };
    gc = {
      automatic = true;
      user = "root";
      interval = {
        # hourly at the 15th minute
        Minute = 15;
      };
      # ensure up to 125G free space every hour
      options =
        let
          gbFree = 50;
        in
        "--max-freed $((${toString gbFree} * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | awk '{ print $4 }')))";
    };
  };

  # Manage user for ofborg, this enables creating/deleting users
  # depending on what modules are enabled.
  users = {
    users.ofborg.home = "/private/var/lib/ofborg";
    users.root = {
      # bash doesn't export /run/current-system/sw/bin to $PATH,
      # which we need for nix-store
      shell = "/bin/zsh";
      # Not part of the infra team
      openssh.authorizedKeys.keys = (import "${inputs.infra}/ssh-keys.nix").infra ++ [
        # Not part of the infra team
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM35Bq87SBWrEcoDqrZFOXyAmV/PJrSSu3hl3TdVvo4C janne"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPK/3rYhlIzoPCsPK38PMdK1ivqPaJgUqWwRtmxdKZrO ✏️"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh cole-h"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3+NUShVVqdTH93fYFIVr0uaZ2zGiU9UEWIFk1sDHID cole-h-2"
      ];
    };
  };

  system.activationScripts.postActivation.text = ''
    printf "disabling spotlight indexing... "
    mdutil -i off -d / &> /dev/null
    mdutil -E / &> /dev/null
    echo "ok"
  '';

  services.prometheus.exporters.node.enable = true;
  # https://github.com/LnL7/nix-darwin/issues/1256
  users.users._prometheus-node-exporter.home = lib.mkForce "/private/var/lib/prometheus-node-exporter";
}
