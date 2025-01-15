{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
    ../../modules/ofborg/builder.nix
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "116.203.67.97";

  networking = {
    hostName = "ofborg-temp02";
    domain = "ofborg.org";
    hostId = "007f0402";
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = "96:00:03:fe:10:3b";
    address = [
      "116.203.67.97/32"
      "2a01:4f8:c2c:2518::/64"
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
    sopsFile = ../../secrets/ofborg.temp02.ofborg.org.yml;
  };
}
