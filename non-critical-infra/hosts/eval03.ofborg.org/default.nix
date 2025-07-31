{ inputs, config, ... }:
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
    ../../modules/ofborg/builder.nix
    ./hardware.nix
    "${inputs.infra}/non-critical-infra/modules/hydra-queue-builder-v2.nix"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "37.27.189.4";

  networking = {
    hostName = "ofborg-eval03";
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

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  system.stateVersion = "24.11"; # Did you read the comment?

  services.hydra-queue-builder-v2 = {
    enable = true;
    queueRunnerAddr = "https://queue-runner.staging-hydra.nixos.org";
    maxJobs = 2;
    mtls = {
      serverRootCaCertPath = "${inputs.infra}/non-critical-infra/hosts/staging-hydra/ca.crt";
      clientCertPath = "${./client.crt}";
      clientKeyPath = config.sops.secrets."queue-runner-client.key".path;
      domainName = "queue-runner.staging-hydra.nixos.org";
    };
  };

  sops.secrets = {
    "ofborg/builder-rabbitmq-password" = {
      owner = "ofborg-builder";
      restartUnits = [ "ofborg-builder.service" ];
      sopsFile = ../../secrets/ofborg.eval03.ofborg.org.yml;
    };
    "harmonia/secret" = {
      owner = "harmonia";
      restartUnits = [ "harmonia.service" ];
      sopsFile = ../../secrets/ofborg.eval03.ofborg.org.yml;
    };
    "queue-runner-client.key" = {
      owner = "hydra-queue-builder";
      restartUnits = [ "hydra-queue-builder-v2.service" ];
      sopsFile = ../../secrets/ofborg.eval03.ofborg.org.yml;
    };
  };
}
