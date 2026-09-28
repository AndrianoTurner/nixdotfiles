# NixOS configuration

This flake contains the configurations for my own machines and a secret-free
QEMU demo for anyone who wants to try my desktop setup.

## Layout

Hosts are the final composition points. Each directory under `hosts/` contains
the machine's NixOS configuration, hardware configuration when applicable, and
a `home.nix` that selects a concrete Home Manager user configuration.

The files under `modules/nixos/common`, `modules/nixos/desktop`,
`modules/nixos/optional`, and `modules/home-manager/features` are ordinary Nix
modules. Hosts and users import them by relative path.

Concrete user configuration lives under both `modules/nixos/users` and
`modules/home-manager/users`.

## Adapt it for another machine

1. Copy one of the directories under `hosts/`, replace its hardware
   configuration, and update the hostname and hardware-specific settings.
2. Copy the relevant NixOS and Home Manager user directories, rename the user,
   and remove or replace personal imports such as SOPS and L2TP.
3. Point the copied host's `home.nix` at the copied Home Manager user module and
   add the host to `nixosConfigurations` in `flake.nix`.

Reusable modules are intentionally plain files: import one as-is, or copy it
and modify it when its defaults do not fit the new machine.

## Run the demo

On an x86_64 Linux host with Nix flakes enabled, run:

```console
nix run .#demo
```

KVM is recommended. The VM uses 4 GiB of memory, four virtual CPUs, and a
1440x900 display.

```text
username: demo
password: demo
```

The writable state is stored in `demo.qcow2` in the launch directory; delete
that file to reset the guest.

The demo shares the desktop, applications, themes, and wallpapers with the
personal hosts.

## Install `chodum`

`chodum` targets the AMD-integrated-graphics Maibenben M557 variant. It uses
one NVMe disk with a 1 GiB EFI partition and a single LUKS2 container. The
container holds an LVM volume group with a 24 GiB swap LV for hibernation and a
btrfs root LV with `/`, `/home`, and `/nix` subvolumes.

This layout erases the selected disk. It does not preserve existing partitions
or support dual boot. Confirm the disk carefully before continuing.

### Prepare the installer

1. Boot a current NixOS installer USB in UEFI mode.
2. Connect to the network. Ethernet is simplest; use `nmtui` for Wi-Fi.
3. Clone this repository and enter it:

   ```console
   git clone https://github.com/AndrianoTurner/nixdotfiles.git ~/nixos
   cd ~/nixos
   ```

4. Identify the internal NVMe disk. Do not assume it is `nvme0n1`:

   ```console
   lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
   ```

### Provision SOPS before the first activation

This host reuses the `andriano` system and Home Manager configuration, so its
system and user age keys must be available before the first activation.
Generate two new key files on a trusted machine, keep them private, and never
commit or print them:

```console
umask 077
age-keygen -o chodum-system.age
age-keygen -o chodum-user.age
```

Add the public recipients from those files to `.sops.yaml` under new
`system_chodum` and `user_chodum` entries, then re-encrypt both existing files
using the repository's normal SOPS workflow:

```console
sops updatekeys secrets/system/shared.yaml
sops updatekeys secrets/users/andriano.yaml
```

The private system key must become
`/var/lib/sops-nix/key.txt`; the private user key must become
`~/.config/sops/age/keys.txt` for `andriano`. After disko mounts the target,
copy the files before running `nixos-install` (adjust the user/group IDs if
they differ from the default `1000:100`):

```console
sudo install -D -m600 chodum-system.age /mnt/var/lib/sops-nix/key.txt
sudo install -D -m600 chodum-user.age /mnt/home/andriano/.config/sops/age/keys.txt
sudo chown -R 1000:100 /mnt/home/andriano/.config/sops
```

Do not put either private key in the repository or paste it into a terminal
transcript.

### Partition, install, and encrypt

Replace `/dev/nvme0n1` below with the disk identified by `lsblk`. The command
is destructive and prompts for the LUKS passphrase:

```console
sudo nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  hosts/chodum/disko.nix
```

If the disk is not `/dev/nvme0n1`, make a temporary copy of
`hosts/chodum/disko.nix`, replace only its `device` value with the verified
path, and pass that copy to the command. Do not commit a machine-specific disk
path.

After disko finishes, verify that the filesystems are mounted under `/mnt`,
securely provision the two SOPS key files under `/mnt`, then install the
configuration:

```console
mount | grep /mnt
sudo nixos-install --root /mnt --flake .#chodum
```

Reboot, remove the installer USB, and enter the same LUKS passphrase at the
initrd prompt. The system resumes hibernation from the encrypted 24 GiB swap
LV. A 16 GiB swap target is the practical minimum for 16 GiB RAM; 24 GiB
leaves useful headroom for normal swap use as well.

The swap LV is a raw block device and cannot use btrfs filesystem compression.
Runtime swap pressure is already handled by `zswap` in
`modules/nixos/physical.nix`, which compresses pages in RAM before they are
written to disk. It is not the hibernation resume device.

### Reinstall or recover

Boot the installer again, clone the repository, verify the target with `lsblk`,
and repeat the disko and `nixos-install` commands. This recreates the same
partition, LUKS, LVM, btrfs, and hibernation layout; restore or re-provision
SOPS keys before activation. Never run the destructive disko command against a
disk containing data you want to keep.
