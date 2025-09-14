{
  disko.devices = {
    disk.main = {
      imageSize = "10G";
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          root = {
            size = "100%";
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
                "/preserve" = {
                  mountpoint = "/preserve";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/preserve/swap" = {
                  mountpoint = "/preserve/swap";
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

  fileSystems."/preserve".neededForBoot = true;
}
