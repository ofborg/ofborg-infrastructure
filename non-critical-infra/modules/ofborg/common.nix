{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.server
    "${inputs.infra}/modules/common.nix"
    "${inputs.infra}/non-critical-infra/modules/common.nix"
    "${inputs.infra}/non-critical-infra/modules/prometheus/node-exporter.nix"
  ];

  # TODO wire up exporters
  # TODO loki

  # Not part of the infra team
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM35Bq87SBWrEcoDqrZFOXyAmV/PJrSSu3hl3TdVvo4C janne"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh cole-h"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3+NUShVVqdTH93fYFIVr0uaZ2zGiU9UEWIFk1sDHID cole-h-2"
  ];

  nixpkgs.overlays = [ (_self: super: {
    ofborg = inputs.ofborg.packages.${super.system}.pkg;
  }) ];

  systemd.targets.ofborg = {
    description = "ofBorg target";
    wantedBy = [ "multi-user.target" ];
  };

  deployment.tags = [ "ofborg" ];
}
