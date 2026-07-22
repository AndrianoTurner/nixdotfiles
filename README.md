# NixOS configuration

This flake contains the configurations for my own machines and a secret-free
QEMU demo for anyone who wants to try my desktop setup.

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

The credentials are intentionally public and only suitable for this demo VM.
The writable state is stored in `demo.qcow2` in the launch directory; delete
that file to reset the guest.

The demo shares the desktop, applications, themes, and wallpapers with the
personal hosts. It does not import sops-nix modules or personal Git identities,
SSH hosts, OpenCode providers, L2TP, hardware tuning, Docker, Steam, or Throne.
