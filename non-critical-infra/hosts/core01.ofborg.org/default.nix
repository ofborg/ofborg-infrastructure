{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.hardware-hetzner-cloud
    "${inputs.infra}/modules/common.nix"
    "${inputs.infra}/non-critical-infra/modules/prometheus/node-exporter.nix"
  ];
  # TODO backups
  # TODO wire up exporters
  # TODO loki

  # Not part of the infra team
  users.users.root.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM35Bq87SBWrEcoDqrZFOXyAmV/PJrSSu3hl3TdVvo4C janne"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh cole-h"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3+NUShVVqdTH93fYFIVr0uaZ2zGiU9UEWIFk1sDHID cole-h-2"
  ];

  # Bootloader.
  boot.loader.grub.enable = true;

  networking = {
    hostName = "core01";
    domain = "ofborg.org";
    hostId = "007f0101";
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = "96:00:03:ea:fa:62";
    address = [
      "138.199.148.47/32"
      "2a01:4f8:c012:cda4::1/64"
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
}
