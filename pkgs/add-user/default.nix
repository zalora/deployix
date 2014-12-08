defnix: { name, comment }: defnix.build-support.write-script "create-${name}" ''
  #!${defnix.pkgs.sh}
  ${defnix.pkgs.shadow}/bin/useradd -c "${comment}" -d /var/empty -e "" -f -1 -g "nogroup" -M -N -r -s "" -u ${toString (defnix.eval-support.calculate-id name)} "${name}"
  res=$?
  if [ "$res" -ne "0" -a "$res" -ne "4" -a "$res" -ne "9" ]; then
    echo "useradd failed with exit code $res" >&2
    exit $res
  fi
''
