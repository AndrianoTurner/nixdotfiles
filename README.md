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
