{ config, pkgs, ... }:

{
  systemd.services.ofborg-github-comment-filter = {
    description = "ofBorg GitHub comment filter";

    wantedBy = [ "ofborg.target" ];
    bindsTo = [ "ofborg.target" ];
    restartTriggers = [ config.environment.etc."ofborg.json".source ];

    stopIfChanged = false;
    serviceConfig = {
      # Filesystem stuff
      ProtectSystem = "strict"; # Prevent writing to most of /
      ProtectHome = true; # Prevent accessing /home and /root
      PrivateTmp = true; # Give an own directory under /tmp
      PrivateDevices = true; # Deny access to most of /dev
      ProtectKernelTunables = true; # Protect some parts of /sys
      ProtectControlGroups = true; # Remount cgroups read-only
      RestrictSUIDSGID = true; # Prevent creating SETUID/SETGID files
      PrivateMounts = true; # Give an own mount namespace
      RemoveIPC = true;
      UMask = "0077";

      Restart = "on-failure";
      ExecStart = "${pkgs.ofborg}/bin/github-comment-filter /etc/ofborg.json";
      User = "ofborg-github-comment-filter";
      Group = "ofborg-github-comment-filter";
      SupplementaryGroups = [ "ofborg-github-oauth-secret" ];

      # Capabilities
      CapabilityBoundingSet = ""; # Allow no capabilities at all
      NoNewPrivileges = true; # Disallow getting more capabilities. This is also implied by other options.

      # Kernel stuff
      ProtectKernelModules = true; # Prevent loading of kernel modules
      SystemCallArchitectures = "native"; # Usually no need to disable this
      ProtectKernelLogs = true; # Prevent access to kernel logs
      ProtectClock = true; # Prevent setting the RTC

      # Misc
      LockPersonality = true; # Prevent change of the personality
      ProtectHostname = true; # Give an own UTS namespace
      RestrictRealtime = true; # Prevent switching to RT scheduling
      MemoryDenyWriteExecute = true; # Maybe disable this for interpreters like python
      PrivateUsers = true; # If anything randomly breaks, it's mostly because of this
      RestrictNamespaces = true;
      SystemCallFilter = "@system-service";
    };
  };

  users.users.ofborg-github-comment-filter = {
    isSystemUser = true;
    group = "ofborg-github-comment-filter";
    description = "ofBorg GitHub comment filter system user";
  };
  users.groups.ofborg-github-comment-filter = {};

  sops.secrets = {
    "ofborg/github-comment-filter-rabbitmq-password" = {
      owner = "ofborg-github-comment-filter";
      restartUnits = [ "ofborg-github-comment-filter.service" ];
      sopsFile = ../../secrets/ofborg.core01.ofborg.org.yml;
    };
    "ofborg/github-oauth-secret".restartUnits = [ "ofborg-github-comment-filter.service" ];
  };
}
