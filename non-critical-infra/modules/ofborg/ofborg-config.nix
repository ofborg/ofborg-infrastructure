let
  rabbitmq = {
    host = "messages.ofborg.org";
    ssl = true;
    virtualhost = "ofborg";
    # Missing: username and password_file
  };
in { config, pkgs, ... }: {
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
    github_comment_poster = {
      rabbitmq = rabbitmq // {
        username = "ofborg-github-comment-poster";
        password_file = "/run/secrets/ofborg/github-comment-poster-rabbitmq-password";
      };
    };
    log_message_collector = {
      rabbitmq = rabbitmq // {
        username = "ofborg-log-message-collector";
        password_file = "/run/secrets/ofborg/log-message-collector-rabbitmq-password";
      };
      logs_path = "/var/log/ofborg";
    };
    mass_rebuilder = {
      rabbitmq = rabbitmq // {
        username = "ofborg-${config.networking.hostName}";
        password_file = "/run/secrets/ofborg/mass-rebuilder-rabbitmq-password";
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
      private_key = "/run/secrets/ofborg/github-app-key"; # Used for submitting statuses
      oauth_client_id = "Iv1.24d6e782e2ccbbdf"; # For accessing the API
      oauth_client_secret_file = "/run/secrets/ofborg/github-oauth-secret"; # For accessing the API
    };

    checkout.root = "/var/lib/ofborg/checkout";
    feedback.full_logs = true;
    nix = {
      build_timeout_seconds = 3600;
      initial_heap_size = "4g";
      remote = "daemon";
      inherit (pkgs) system;
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
      sopsFile = ../../secrets/github-tokens.ofborg.org.yml;
    };
    "ofborg/github-app-key" = {
      mode = "0440";
      group = "ofborg-github-app-key";
      sopsFile = ../../secrets/github-tokens.ofborg.org.yml;
    };
  };
  users.groups."ofborg-github-oauth-secret" = {};
  users.groups."ofborg-github-app-key" = {};
}
