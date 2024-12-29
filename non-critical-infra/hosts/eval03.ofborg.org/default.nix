{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
    ../../modules/ofborg/evaluator.nix
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "37.27.189.4";

  networking = {
    hostName = "eval03";
    domain = "ofborg.org";
    hostId = "007f0203";
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = "96:00:03:f4:25:ed";
    address = [
      "37.27.189.4/32"
      "2a01:4f9:c012:e37b::1/64"
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

  system.stateVersion = "24.11"; # Did you read the comment?

  sops.secrets."ofborg/mass-rebuilder-rabbitmq-password" = {
    owner = "ofborg-mass-rebuilder";
    restartUnits = [ "ofborg-mass-rebuilder.service" ];
    sopsFile = ../../secrets/ofborg.eval03.ofborg.org.yml;
  };
}
