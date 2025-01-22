{
  config,
  pkgs,
  lib,
  ...
}:
{
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
    knownGroups = [ "ofborg" ];
    knownUsers = [ "ofborg" ];
    users.ofborg.home = "/private/var/lib/ofborg";
    # bash doesn't export /run/current-system/sw/bin to $PATH,
    # which we need for nix-store
    users.root.shell = "/bin/zsh";
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
