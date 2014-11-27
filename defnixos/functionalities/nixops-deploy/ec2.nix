{ name
, region ? "us-west-2"
, accessKeyId ? "devops"
}: builtins.toFile "ec2.nix" ''
  let
    region = "${region}";

    accessKeyId = "${accessKeyId}";
  in {
    resources.ec2KeyPairs.${name}-key = {
      inherit region accessKeyId;
    };

    resources.ec2SecurityGroups.${name}-group = {
      description = "${name} security group";

      inherit region accessKeyId;

      rules = [
        {
          fromPort = 22;

          toPort = 22;

          sourceIp = "0.0.0.0/0";
        }

        {
          fromPort = 500;

          toPort = 500;

          protocol = "udp";

          sourceIp = "0.0.0.0/0";
        }

        {
          fromPort = 4500;

          toPort = 4500;

          protocol = "udp";

          sourceIp = "0.0.0.0/0";
        }
      ];
    };

    machine = { resources, ... }: {
      deployment = {
        targetEnv = "ec2";

        ec2 = {
          inherit region accessKeyId;

          instanceType = "m3.medium";

          securityGroups = [ resources.ec2SecurityGroups.${name}-group ];

          keyPair = resources.ec2KeyPairs.${name}-key;
        };
      };

      networking.firewall.enable = false;
    };
  }
''
