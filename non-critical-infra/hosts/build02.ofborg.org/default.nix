{ inputs, config, ... }:
{
  imports = [
    ../../modules/ofborg/builder.nix
    ./hardware.nix
    "${inputs.infra}/non-critical-infra/modules/hydra-queue-builder-v2.nix"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "185.119.168.11";

  networking = {
    hostName = "ofborg-build02";
    domain = "ofborg.org";
    hostId = "007f0302";
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = "22:33:4d:07:51:b4";
    address = [ "185.119.168.11/32" ];
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

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

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

  system.stateVersion = "24.11"; # Did you read the comment?

  sops.secrets = {
    "ofborg/builder-rabbitmq-password" = {
      owner = "ofborg-builder";
      restartUnits = [ "ofborg-builder.service" ];
      sopsFile = ../../secrets/ofborg.build02.ofborg.org.yml;
    };
    "harmonia/secret" = {
      owner = "harmonia";
      restartUnits = [ "harmonia.service" ];
      sopsFile = ../../secrets/ofborg.build02.ofborg.org.yml;
    };
    "queue-runner-client.key" = {
      owner = "hydra-queue-builder";
      restartUnits = [ "hydra-queue-builder-v2.service" ];
      sopsFile = ../../secrets/ofborg.build02.ofborg.org.yml;
    };
  };
}
