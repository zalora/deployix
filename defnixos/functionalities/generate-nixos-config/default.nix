defnix: let
  inherit (defnix.native.build-support) write-script;

  inherit (defnix.native.pkgs) sh;

  inherit (defnix.lib) join fold map-attrs-to-list;

  defer = pkg: ({ context, string }:
    fold (ctx: acc: let
      ctxstr = if ctx.subtype == "drv"
        then "(import ${ctx.path}).drvPath"
      else if ctx.subtype == "output"
        then "(import ${ctx.path}).${ctx.output}"
      else if ctx.subtype == "drv-as-source"
        then "(builtins.unsafeDiscardOutputDependency "
               + "(import ${ctx.path}).drvPath)"
      else if ctx.subtype == "source"
        then "(builtins.storePath ${ctx.path})"
        else throw "Unknown context string ${ctx.path}";
    in "((builtins.substring 0 0 ${ctxstr}) + ${acc})") ''"${string}"'' context
  ) (defnix.eval-support.extract-context pkg);

  deferred-notify-readiness = defer defnix.pkgs.notify-readiness;

  on-demand-svc-strings = indent: name: service: let
    listen-run = defnix.build-support.write-script "${name}-listen" ''
      #!${defnix.pkgs.sh} -e
      ${toString service.initializer or ""}
      mkdir -p /run/defnixos-services/${name}
      cd /run/defnixos-services/${name}
      exec ${service.start}
    '';

    listen-service =
                     "\"${name}\" = {"
      +   "\n${indent}  description = \"${name}\";"

      + "\n\n${indent}  serviceConfig.ExecStart = ${defer listen-run};"

      + "\n\n${indent}  serviceConfig.Type = \"notify\";"

      + "\n\n${indent}  wantedBy = [ \"on-demand.target\" ];"

      + "\n\n${indent}  before = [ \"on-demand.target\" ];"
      +   "\n${indent}};";

    ready-service =
                     "\"${name}-ready\" = {"
      +   "\n${indent}  description = \"${name} readiness notification\";"

      + "\n\n${indent}  serviceConfig.ExecStart = ${deferred-notify-readiness};"

      + "\n\n${indent}  serviceConfig.WorkingDirectory = "
                          + "\"/run/defnixos-services/${name}\";"

      + "\n\n${indent}  serviceConfig.Type = \"oneshot\";"

      + "\n\n${indent}  serviceConfig.RemainAfterExit = true;"

      + "\n\n${indent}  serviceConfig.BindsTo = [ \"${name}.service\" ];"

      + "\n\n${indent}  after = [ \"${name}.service\" ];"

      + "\n\n${indent}  wantedBy = [ \"defnixos.target\" ];"
      +   "\n${indent}};";
  in [ listen-service ready-service ];

  regular-svc-strings = indent: name: service: let
    run = write-script "${name}-exec" ''
      #!${sh} -e
      ${toString service.initializer or ""}
      mkdir -p /run/defnixos-services/${name}
      cd /run/defnixos-services/${name}
      exec ${service.start}
    '';
  in [ (
                   "\"${name}\" = {"
    +   "\n${indent}  description = \"${name} service\";"
    + "\n\n${indent}  serviceConfig.ExecStart = ${defer run};"
    + "\n\n${indent}  wantedBy = [ \"defnixos.target\" ];"
    +   "\n${indent}};"
  ) ];

  functionality-to-svc-strings = indent: name: { service, ... }:
    (if service.on-demand or false
      then on-demand-svc-strings
      else regular-svc-strings) indent name service;
in functionalities: defnix.native.build-support.write-file "machine.nix" ''
  { ... }:
  {
    config.systemd.services = {
      ${join "\n    " (builtins.concatLists (
        map-attrs-to-list (functionality-to-svc-strings "    ") functionalities
       ))}
    };

    config.systemd.targets = {
      defnixos = {
        description = "defnixos services";

        unitConfig.X-StopOnReconfiguration = true;
      };

      on-demand = {
        description = "on-demand defnixos services";

        wants = [ "defnixos.target" ];

        before = [ "defnixos.target" ];

        wantedBy = [ "multi-user.target" ];

        unitConfig.X-StopOnReconfiguration = true;
      };
    };
  }
''
