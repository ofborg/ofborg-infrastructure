{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
    ../../modules/ofborg/builder.nix
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "159.69.29.247";

  networking = {
    hostName = "ofborg-temp01";
    domain = "ofborg.org";
    hostId = "007f0401";
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = "96:00:03:fe:10:3c";
    address = [
      "159.69.29.247/32"
      "2a01:4f8:1c1b:e2c6::/64"
    ];
    routes = [
      { Gateway = "fe80::1"; }
      {
        Gateway = "172.31.1.1";
        GatewayOnLink = true;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  system.stateVersion = "24.11"; # Did you read the comment?

  sops.secrets."ofborg/builder-rabbitmq-password" = {
    owner = "ofborg-builder";
    restartUnits = [ "ofborg-builder.service" ];
    sopsFile = ../../secrets/ofborg.temp01.ofborg.org.yml;
  };
}
