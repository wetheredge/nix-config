{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = ["--label" "nixos" "--force"];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/state" = {
                    mountpoint = "/state";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/state/swap" = {
                    mountpoint = "/state/swap";
                    mountOptions = ["nodatacow" "noatime"];
                    swap.swapfile.size = "10G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/state".neededForBoot = true;
}
