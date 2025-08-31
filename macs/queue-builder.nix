{
  config,
  inputs,
  ...
}:

{
  imports = [
    ./module/hydra-queue-builder.nix
  ];

  services.hydra-queue-builder-v2 = {
    enable = true;
    queueRunnerAddr = "https://queue-runner.staging-hydra.nixos.org";
    maxJobs = 2;
    mtls = {
      serverRootCaCertPath = "${inputs.infra}/non-critical-infra/hosts/staging-hydra/ca.crt";
      clientCertPath = ./ca/client-${config.networking.hostName}.crt;
      clientKeyPath = config.sops.secrets."queue-runner-client.key".path;
      domainName = "queue-runner.staging-hydra.nixos.org";
    };
  };

  sops.secrets."queue-runner-client.key" = {
    owner = "hydra-queue-builder";
    sopsFile = ./secrets/${config.networking.hostName}.yml;
  };
}
