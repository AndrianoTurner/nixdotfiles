# NixOS configuration

This flake contains the configurations for my own machines and a secret-free
QEMU demo for anyone who wants to try my desktop setup.

## Layout

Hosts are the final composition points. Each directory under `hosts/` contains
the machine's NixOS configuration, hardware configuration when applicable, and
a `home.nix` that selects a concrete Home Manager user configuration.

The files under `modules/nixos/common`, `modules/nixos/desktop`,
`modules/nixos/optional`, and `modules/home-manager/features` are ordinary Nix
modules. Host-level imports use the `repoRoot` path passed by the flake;
imports within a module subtree stay relative.

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

## Install a host with `nixos-anywhere`

Use this procedure for any host registered in `nixosConfigurations` that
imports a disko configuration. Replace the placeholders below with the host,
user, target address, and disk for that machine.

`nixos-anywhere` connects to the target over SSH, boots a temporary NixOS
installer with kexec, lets disko partition and format the target, installs the
flake configuration, and reboots. The disko step is destructive: it erases the
configured disk and does not preserve existing partitions or dual-boot data.
Verify the target and disk before running it.

### Prerequisites

- A source machine with Nix flakes enabled and this repository checked out.
- An x86_64 Linux target reachable over wired networking and SSH. The target
  needs root SSH access or a user with passwordless `sudo`; nixos-anywhere does
  not configure Wi-Fi for the temporary installer.
- The target host is registered in `flake.nix`, imports its disko module, and
  has SSH access configured for the first boot.
- If hardware configuration is generated during installation, the host module
  must import `./hardware-configuration.nix` before running the command.

For a target booted from a NixOS installer USB, enable SSH in the installer and
use its address. Otherwise nixos-anywhere normally uses kexec to boot its
installer. See the [upstream documentation](https://github.com/nix-community/nixos-anywhere)
for targets that need a custom installer image.

### Prepare the host and disk

Clone the repository on the source machine, set these values for the target,
and inspect its disks:

```console
git clone https://github.com/AndrianoTurner/nixdotfiles.git ~/nixos
cd ~/nixos
host=replace-me
target=replace-me
user=replace-me
ssh "root@$target" lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
```

Set the `device` in `hosts/<host>/disko.nix` to the verified target disk.
Prefer a stable `/dev/disk/by-id/...` path when available. `nixos-anywhere`
uses the disko device from the flake; it does not infer a disk or provide a
separate disk override. Commit the host-specific storage choice only if it is
meant to be part of that host configuration.

If the host needs a generated hardware file, make sure its module imports the
file, then include this flag in the install command:

```console
--generate-hardware-config nixos-generate-config "hosts/$host/hardware-configuration.nix"
```

The generated file excludes filesystem declarations because disko owns the
filesystems. Omit this flag when the host already has a suitable hardware
configuration.

### Install without extra secrets

Run this from the repository root. The command builds the selected
`nixosConfigurations.<host>`, formats the configured disk, installs it, and
reboots the target:

```console
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$host" \
  --target-host "root@$target"
```

Use `--build-on remote` if the source machine cannot build the target's system
architecture. To test the flake and disko layout without touching a target,
use `--vm-test` instead.

### Install a host using SOPS

Do this on a trusted machine. You can reuse an existing system age identity
instead of generating one: it only needs to be copied to
`/var/lib/sops-nix/key.txt` on the target. Add its public recipient to
`.sops.yaml` if it is not already present.

You can also derive the user age identity from an existing SSH private key.
This is technically supported, but separate SSH and SOPS keys are safer because
compromising one key would otherwise grant both SSH access and secret access.
The SSH private key must be available outside SOPS; a key encrypted inside the
user SOPS file cannot decrypt that same file initially.

```console
umask 077
system_key=/secure/path/system.age
ssh_key=/secure/path/id_ed25519
age-keygen -y "$system_key"              # public recipient
nix shell nixpkgs#ssh-to-age --command \
  ssh-to-age -i "$ssh_key" -private-key -o user.age
age-keygen -y user.age                     # public recipient
```

Add those public recipients to `.sops.yaml`, then re-encrypt the encrypted
files used by that host. Never commit, print, or paste private keys:

```console
sops updatekeys secrets/system/shared.yaml
sops updatekeys "secrets/users/$user.yaml"
```

Stage the keys outside the repository. Use the numeric UID and GID declared by
the host's user configuration:

```console
uid=1000
gid=100
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
install -D -m600 "$system_key" "$stage/var/lib/sops-nix/key.txt"
install -D -m600 user.age "$stage/home/$user/.config/sops/age/keys.txt"
```

Pass that directory to nixos-anywhere. `--extra-files` copies it into `/mnt`
before installation; `--chown` fixes ownership of the user key in the new
system. Omit the user key and its `--chown` flag when the host has no user SOPS
configuration.

The keys do not need to survive in the live installer. nixos-anywhere reads
them from the source machine, runs disko, copies the staged files into the
mounted target filesystem, and then runs `nixos-install`. The live environment
is discarded on reboot, but `/mnt/var/lib/sops-nix/key.txt` and
`/mnt/home/$user/.config/sops/age/keys.txt` become files in the installed
system. `--disk-encryption-keys` is different: it is for temporary installer
keys used to unlock disks, not for persistent SOPS keys.

```console
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$host" \
  --target-host "root@$target" \
  --extra-files "$stage" \
  --chown "/home/$user/.config/sops" "$uid:$gid" \
  --generate-hardware-config nixos-generate-config "hosts/$host/hardware-configuration.nix"
```

The generated hardware flag and SOPS options are independent: omit either when
that host already has hardware configuration or does not use SOPS. Remove any
temporary key files after the installation completes.

### After installation

Log in with an account enabled by the new configuration. If the machine was
reinstalled, remove its old SSH host key before reconnecting:

```console
ssh-keygen -R "$target"
ssh "$user@$target"
```

Future changes can be deployed remotely from the repository with:

```console
nixos-rebuild switch --flake ".#$host" --target-host "$user@$target"
```

To reinstall, verify the disk again and rerun the command. Never run the
destructive installation against a disk containing data you want to keep.
