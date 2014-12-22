defnix: let
  inherit (defnix.build-support) write-script run-script;

  inherit (defnix.pkgs) sh coreutils systemd gnugrep nix diffutils
    notify-readiness;

  inherit (defnix.lib) join map-attrs-to-list hashless-basename;

  activate = write-script "defnixos-systemd-activate" ''
    #!${sh} -e

    shopt -s nullglob

    if [ "$#" -ne 1 ]; then
      echo "Usage: $0 CLOSURE" >&2
      exit 1
    fi

    closure=$(readlink -f $1)
    prefix=$(cat $closure/prefix)

    export PATH=${join ":" (map (x: "${x}/bin") [
      coreutils
      systemd
      gnugrep
      nix
      diffutils
    ])}

    unit_dir=/etc/systemd/system
    if [ $(grep ^ID /etc/os-release) = "ID=nixos" ]; then
      unit_dir=/etc/systemd-mutable/system
    fi
    mkdir -p $unit_dir

    to_stop=()
    to_delete=()
    if [ -e /nix/var/nix/profiles/defnixos/$prefix ]; then
      previous=$(readlink -f /nix/var/nix/profiles/defnixos/$prefix)
      if [ "$previous" = "$closure" ]; then
        echo "Previous gen of $prefix is identical, not doing anything" >&2
        exit 0
      fi
      for filename in $previous/*.service; do
        svc=$(basename $filename)
        if [ ! -e $closure/$svc ]; then
          if [ -e $unit_dir/$svc ]; then
            to_stop+=($svc)
            to_delete+=$($unit_dir/$svc)
          fi
        fi
      done
    fi

    profile=/nix/var/nix/profiles/defnixos/$prefix

    to_restart=(defnixos-$prefix.target on-demand-$prefix.target)
    for filename in $closure/*.service; do
      svc=$(basename $filename)
      if [ -e $unit_dir/$svc ]; then
        if diff $unit_dir/$svc $filename &>/dev/null; then
          continue
        fi
      fi
      ln -sf $profile/$svc $unit_dir
      to_restart+=($svc)
    done
    for filename in $closure/{*.wants,*.target}; do
      base=$(basename $filename)
      ln -sfT $profile/$base $unit_dir/$base
    done
    mkdir -p $unit_dir/multi-user.target.wants
    ln -sf ../defnixos-$prefix.target $unit_dir/multi-user.target.wants

    if [ ''${#to_stop[@]} -ne 0 ]; then
      echo Stopping the following units: ''${to_stop[@]} >&2
      systemctl stop ''${to_stop[@]}
    fi

    $closure/initialize

    nix-env --set -p $profile $closure

    if [ ''${#to_delete[@]} -ne 0 ]; then
      echo Deleting the following obsolete units: ''${to_delete[@]} >&2
      rm -f ''${to_delete[@]}
    fi

    echo Reloading systemd >&2
    systemctl daemon-reload

    echo (Re)starting the following units: ''${to_restart[@]} >&2
    systemctl reload-or-restart ''${to_restart[@]}
  '';
in service-prefix: functionalities: let
  units-dir = run-script "${service-prefix}-units" {
    PATH = "${coreutils}/bin";
  } ''
    #!${sh} -e

    mkdir -p $out/{on-demand,defnixos}-${service-prefix}.target.wants

    echo -n ${service-prefix} > $out/prefix

    echo '#!'${sh} -e > $out/initialize
    chmod +x $out/initialize
    ${join "\n" (map-attrs-to-list (name: { service
                                          , singleton ? false
                                          , ... 
                                          }: let
      service-name = if singleton then name else "${service-prefix}-${name}";

      on-demand = service.on-demand or false;

      runtime-dir = "/run/defnixos-services/${service-name}";

      initializer = service.initializer or null;
    in ''
      cat > $out/${service-name}.service <<EOF
      [Unit]
      Description=${service-name} service
      ${if on-demand then "" else "After=on-demand-${service-prefix}.target"}

      [Service]
      ExecStart=@${service.start} ${hashless-basename service.start}
      ExecStartPre=@${coreutils}/bin/mkdir mkdir -p ${runtime-dir}
      WorkingDirectory=${runtime-dir}
      Type=${if on-demand then "notify" else "simple"}
      EOF
      ln -sv ../${service-name}.service $out/${if on-demand
        then "on-demand"
        else "defnixos"
      }-${service-prefix}.target.wants
      ${if on-demand then ''
        cat > $out/${service-name}-ready.service <<EOF
        [Unit]
        After=${service-name}.service on-demand-${service-prefix}.target
        BindsTo=${service-name}.service
        Description=${service-name} readiness notification

        [Service]
        ExecStart=@${notify-readiness} notify-readiness
        Type=oneshot
        RemainAfterExit=true
        WorkingDirectory=${runtime-dir}
        EOF
        ln -sv ../${service-name}-ready.service $out/defnixos-${
          service-prefix
        }.target.wants
      '' else ""}
      ${if initializer != null then ''
        echo echo Initializing ${service-name} '>&2' >> $out/initialize
        echo ${initializer} >> $out/initialize
      '' else ""}
    '') functionalities)}
    cat > $out/defnixos-${service-prefix}.target <<EOF
    [Unit]
    Description=defnixos ${service-prefix} services
    Wants=on-demand-${service-prefix}.target
    EOF

    cat > $out/on-demand-${service-prefix}.target <<EOF
    [Unit]
    Description=defnixos ${service-prefix} on-demand services
    EOF
  '';
in write-script "defnixos-${service-prefix}-activate" ''
  #!${sh} -e

  export PATH=${join ":" (map (x: "${x}/bin") [
    coreutils
    diffutils
    nix
  ])}

  script=/nix/var/nix/profiles/defnixos/activate
  mkdir -p $(dirname $script)

  if diff $script ${activate} &>/dev/null; then
    :
  else
    nix-env --set -p $script ${activate}
  fi

  exec $script ${units-dir}
''
