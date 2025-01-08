{ inputs, ... }:

{
  imports = [
    ../../modules/ofborg/builder.nix
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "185.119.168.13";

  networking = {
    hostName = "ofborg-build04";
    domain = "ofborg.org";
    hostId = "007f0304";
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = "22:33:4d:06:4a:ad";
    address = [ "185.119.168.13/32" ];
    routes = [
      {
        Gateway = "91.224.148.0";
        GatewayOnLink = true;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ5hBVVKK72ZX+n+BVnPocx+AG5u6ht8bM++G1lhufp liberodark@gmail.com"
  ];

  system.stateVersion = "24.11"; # Did you read the comment?

  /*sops.secrets."ofborg/mass-rebuilder-rabbitmq-password" = {
    owner = "ofborg-mass-rebuilder";
    restartUnits = [ "ofborg-mass-rebuilder.service" ];
    sopsFile = ../../secrets/ofborg.eval01.ofborg.org.yml;
  };*/
}
