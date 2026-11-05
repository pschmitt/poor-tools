{ packageForSystem }:
{
  config,
  lib,
  ...
}:
let
  cfg = config.services.poor-installer-web;
  pkg = packageForSystem config.nixpkgs.hostPlatform.system;
in
{
  options.services.poor-installer-web = {
    enable = lib.mkEnableOption "poor-tools web installer";

    bindPort = lib.mkOption {
      type = lib.types.port;
      default = 7667;
      description = "Port to listen on";
    };

    bindHost = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host to bind to";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.poor-installer-web = {
      description = "poor-tools web installer";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        BIND_HOST = cfg.bindHost;
        BIND_PORT = toString cfg.bindPort;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkg}/bin/poor-installer-web";
        Restart = "always";
        RestartSec = 10;

        # Security hardening
        DynamicUser = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
      };
    };
  };
}
