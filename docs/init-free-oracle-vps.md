# Initializing Free Oracle VPSs

Oracle's free AMD E2.1.Micro instances have only 1gb ram, which isn't enough
for most NixOS installation methods. Instead, we can netboot Alpine, scp a disk
image, manually expand it, then reboot into that:

1. [New tailscale auth key](https://login.tailscale.com/admin/settings/keys)
   with `tag:server`
2. Build image (`just build $host`) & compress with zstd
3. Install [netboot.xyz shim](https://boot.netboot.xyz) into /boot on target
4. Launch a Cloud Shell from $instance > OS Management > Console connection
5. Reboot VPS into Alpine
  1. <kbd>esc</kbd> in the console during boot to get to BIOS
  2. Boot Menu > EFI Internal Shell
  3. `FS0:netboot.xyz.efi` (only accepts \\ as path separator)
  4. Linux Network Installs > Alpine
  5. root / no password
  6. `apk add btrfs-progs openssh parted zstd`
  7. Set a root password
  8. `echo PermitRootLogin yes >> /etc/ssh/sshd_config && rc-service sshd start`
6. `ssh root@$vpsIp 'zstd -d | dd of=/dev/sda' < $img.raw.zst`
7. Expand /dev/sda2 with parted
8. `mount -t btrfs /dev/sda2 /mnt && btrfs filesystem resize max /mnt`
10. Reboot

## Sources

- https://prithu.dev/notes/installing-nixos-on-oracle-cloud-arm-instance/
