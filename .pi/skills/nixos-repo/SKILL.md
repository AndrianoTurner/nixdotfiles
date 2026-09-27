---
name: nixos-repo
description: Navigate and modify this NixOS flake (hosts, NixOS modules, home-manager features, overlays, secrets). Use when adding or changing any host, module, package, user, or secret in this repo.
---

# NixOS repo map

Read this before editing. Do not re-explore the tree or the README to find
where a change belongs; the routing tables below are authoritative. For
verification commands see `.pi/skills/nixos-checks/SKILL.md`.

## Hard rules

- The demo configuration must stay secret-free. Both `hosts/demo/default.nix`
  and `modules/home-manager/users/demo/default.nix` assert that sops is not
  imported. Never add sops, personal accounts, or private keys to demo.
- Never print, diff, or commit decrypted secrets. Secrets are sops-encrypted
  YAML; only edit them through `sops`.
- `hosts/*/hardware-configuration.nix` is machine-generated. Regenerate with
  `nixos-generate-config` on that machine; do not hand-edit for another host.
- Activation (`nh os switch`, `nixos-rebuild switch/test/boot`) is a human
  action: it needs sudo and mutates the running system. Agents build and check
  only, unless the user explicitly asks to activate.
- New files are invisible to flake commands until `git add`ed (untracked files
  are excluded from the flake source).

## Layout

- `flake.nix` — inputs; `nixosConfigurations` registry (add new hosts here);
  `specialArgs` pass `inputs` and `self.outputs` to every module; `formatter`
  is alejandra; `checks.format` runs the format gate; `apps.demo` runs the VM.
- `hosts/<host>/` — `default.nix` composes modules, hardware, network, GPU and
  `home-manager.users.<user> = import ./home.nix`; `home.nix` imports the
  Home Manager user module; `hardware-configuration.nix` per machine.
- `modules/nixos/common/` — imported by every host: home-manager wiring
  (`useGlobalPkgs`, `extraSpecialArgs`), overlays from `self.outputs`, nix
  settings, locales/timezone, security. Secret-free.
- `modules/nixos/desktop/` — niri and the noctalia greeter.
- `modules/nixos/physical.nix` — physical-machine base.
- `modules/nixos/optional/<feature>.nix` — opt-in system features, imported
  explicitly by the hosts that want them.
- `modules/nixos/users/<user>/` — system-level user config (groups, ssh keys,
  sops, per-user optional imports).
- `modules/home-manager/shared/` — imported by every HM user (nh, git, home
  manager, wallpapers, cursor).
- `modules/home-manager/features/cli/` and `features/desktop/` — feature
  modules, each with an aggregating `default.nix`.
- `modules/home-manager/users/<user>/` — the concrete HM user, imports
  `shared`, `features/cli`, `features/desktop` plus personal modules.
- `overlays/default.nix` — `pkgs.unstablePkgs` (nixpkgs-unstable),
  `pkgs.oldPkgs` (nixpkgs-25); `pkgs/default.nix` is the (currently empty)
  custom package set.
- `secrets/` + `.sops.yaml` — sops configuration and encrypted files.

## Hosts

| Host | Notable contents |
| --- | --- |
| `freedompc` | Current machine. Nvidia PRIME (amdgpu + nvidia), systemd-boot, docker, steam, throne, l2tp |
| `homepc` | AMD ROCm/OpenCL, grub-boot, docker, throne |
| `mdr018` | Static IP 172.16.20.2, systemd-boot, docker, throne, searxng, qemu |
| `demo` | QEMU VM, user `demo`/`demo`, no sops, shares the andriano desktop features |

## No auto-discovery

Every directory is wired by explicit relative imports:

- A new file in `modules/home-manager/features/cli/` must be added to
  `features/cli/default.nix`; desktop similarly to `features/desktop/default.nix`.
- A new `modules/nixos/optional/*.nix` must be imported by each host that wants it.
- A new host must be added to `nixosConfigurations` in `flake.nix`.

## Where does a change go?

| Change | Destination |
| --- | --- |
| CLI tool for all HM users | `modules/home-manager/features/cli/<tool>.nix` + aggregator import |
| Desktop app / niri setting | `modules/home-manager/features/desktop/<app>.nix` + aggregator import |
| andriano-only home config (git, ssh, pi, opencode, sops) | `modules/home-manager/users/andriano/<name>.nix` + import in that user's `default.nix` |
| User packages | `home.packages` in the owning HM user module; system-wide in `environment.systemPackages` |
| System service / hardware feature | `modules/nixos/optional/<name>.nix` + host import |
| Shared system behavior | `modules/nixos/common/` (every host) |
| Host hardware, network, GPU | `hosts/<host>/default.nix` |
| Custom package / override | `pkgs/default.nix` or a new overlay in `overlays/default.nix` |
| New machine | Copy `hosts/<closest>`, set hostname + hardware, point `home.nix` at the right HM user, register in `flake.nix`, extend `.sops.yaml` with the new age keys |
| New secret | `secrets/users/andriano.yaml` (user) or `secrets/system/shared.yaml` (system), then reference in a module |

## Secrets workflow

- User secrets: `secrets/users/andriano.yaml`, decrypted with the age key at
  `~/.config/sops/age/keys.txt` (installed by
  `modules/home-manager/users/andriano/sops.nix`).
- System secrets: `secrets/system/shared.yaml`, age key at
  `/var/lib/sops-nix/key.txt` (`modules/nixos/users/andriano/sops.nix`).
- Edit: `sops secrets/users/andriano.yaml` (opens `$EDITOR`, re-encrypts on
  save). Never edit the ciphertext by hand.
- Consume in Nix:
  - `sops.secrets.<name> = {};` → plaintext file under the runtime secrets dir,
  - `config.sops.placeholder.<name>` → use inside settings that must not embed
    the value (see `modules/home-manager/users/andriano/opencode.nix`),
  - `sops.templates."<path>".content` for generated files.
- New host or key rotation: add the age recipient to `.sops.yaml` under the
  right creation rule, then `sops updatekeys <file>` for every affected file.
- `demo` never imports sops; the assertions enforce this.

## Conventions

- Plain relative imports; no module auto-discovery anywhere.
- Format with alejandra: `nix fmt .` (bare `nix fmt` reads stdin on this Nix version).
- Use `lib.mkDefault`/`lib.mkForce` when a value is meant to be overridable or
  must win over another module (see `modules/nixos/common/default.nix`).
- NixOS `system.stateVersion` is per host; Home Manager `stateVersion` defaults
  to `22.05` in `modules/home-manager/shared/default.nix`. Do not change them
  casually.
- `nixpkgs.config.allowUnfree = true` is set globally in `modules/nixos/common`.
- Keep modules small and keyed by feature; follow the style of the file you edit.

## Verification

Run the gates from `.pi/skills/nixos-checks/SKILL.md` before reporting work as
done.
