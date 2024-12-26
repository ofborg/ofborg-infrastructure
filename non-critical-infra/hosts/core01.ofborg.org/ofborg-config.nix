let
  rabbitmq = {
    host = "messages.ofborg.org";
    ssl = true;
    virtualhost = "ofborg";
    # Missing: username and password_file
  };
in {
  environment.etc."ofborg.json".text = builtins.toJSON {
    github_webhook_receiver = {
      listen = "[::1]:9899";
      webhook_secret_file = "/run/secrets/ofborg/github-webhook-secret";
      rabbitmq = rabbitmq // {
        username = "ofborg-github-webhook";
        password_file = "/run/secrets/ofborg/github-webhook-rabbitmq-password";
      };
    };
    evaluation_filter = {
      rabbitmq = rabbitmq // {
        username = "ofborg-evaluation-filter";
        password_file = "/run/secrets/ofborg/evaluation-filter-rabbitmq-password";
      };
    };
    runner = {
      identity = "ofborg-core";
      repos = [
        "nixos/nixpkgs"
        "ofborg/testpkgs"
      ];
      disable_trusted_users = true;
      trusted_users = []; # disabled so everyone can build
    };

    checkout.root = "/ofborg/checkout";
    feedback.full_logs = true;
    github.token_file = "/run/agenix/github_token_file";
    github_app = {
      app_id = 20500;
      private_key = "/run/agenix/github_app_key_file";
    };
    log_storage.path = "/var/log/ofborg";
    nix = {
      build_timeout_seconds = 3600;
      initial_heap_size = "4g";
      remote = "daemon";
      system = "x86_64-liinux";
    };
    rabbitmq = {
      host = "devoted-teal-duck.rmq.cloudamqp.com";
      password_file = "/run/agenix/rabbitmq_ofborgsrvc_password_file";
      ssl = true;
      username = "ofborgsrvc";
      virtualhost = "ofborg";
    };

  };
}
