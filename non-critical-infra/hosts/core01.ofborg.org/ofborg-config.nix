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
    github_comment_filter = {
      rabbitmq = rabbitmq // {
        username = "ofborg-github-comment-filter";
        password_file = "/run/secrets/ofborg/github-comment-filter-rabbitmq-password";
      };
    };
    runner = {
      identity = "ofborg-core"; # TODO what is this
      repos = [
        "nixos/nixpkgs"
        "ofborg/testpkgs"
      ];
      disable_trusted_users = true;
      trusted_users = []; # disabled so everyone can build
    };
    github_app = {
      app_id = 20500; # Used for submitting statuses
      private_key = "/run/agenix/github_app_key_file"; # Used for submitting statuses
      oauth_client_id = "Iv1.24d6e782e2ccbbdf"; # For accessing the API
      oauth_client_secret_file = "/run/secrets/ofborg/github-oauth-secret"; # For accessing the API
    };

    checkout.root = "/ofborg/checkout";
    feedback.full_logs = true;
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

  # Secrets that are shared between components
  sops.secrets = {
    "ofborg/github-oauth-secret" = {
      mode = "0440";
      group = "ofborg-github-oauth-secret";
      sopsFile = ../../secrets/ofborg.core01.ofborg.org.yml;
    };
  };
  users.groups."ofborg-github-oauth-secret" = {};
}
