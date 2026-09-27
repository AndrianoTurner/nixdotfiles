---
name: nixos-checks
description: Canonical read-only checks for this NixOS flake (format gate, eval gate, per-host builds, demo VM, secrets validation). Use before reporting any change as done, when asked to verify changes, or as the checker/final gate.
---

# Checking changes in this repo

Run the gates from this file. Do not invent new commands or explore the tree to
figure out how to test something. All commands here are read-only; none of them
touch the running system. See `.pi/skills/nixos-repo/SKILL.md` for where
changes belong.

Work from the repo root. `nh`, `nixos-rebuild`, and `sops` are on PATH;
`alejandra` is available only through `nix fmt` and `.#checks`.

## Gates

Format gate (seconds once evaluated):

```console
nix build .#checks.x86_64-linux.format
```

Fix with `nix fmt .` (alejandra over the whole flake).

Eval gate — all four hosts, no builds:

```console
nix flake check --no-build
```

Single host:

```console
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
```

Build gate — current machine (`freedompc`):

```console
nh os build .
```

Any host:

```console
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link
```

Full gate — format check plus builds of all four host toplevels:

```console
nix flake check
```

Demo gate:

```console
nix build .#nixosConfigurations.demo.config.system.build.vm --no-link
```

Manual smoke test only (interactive GTK window, login `demo`/`demo`):
`nix run .#demo`.

Secrets gate:

```console
sops -d secrets/users/andriano.yaml > /dev/null
sudo sops -d secrets/system/shared.yaml > /dev/null
```

## Picking the gates

| Change | Minimum | Preferred |
| --- | --- | --- |
| One host file or host-specific setting | eval that host | build that host |
| Shared NixOS module (`common`, `desktop`, `optional`), HM feature/shared module | `nix flake check --no-build` | build `freedompc` + `demo` |
| `demo` host | eval demo | demo VM build |
| `overlays/`, `pkgs/`, `flake.nix`, `flake.lock` | `nix flake check --no-build` | full `nix flake check` |
| Secrets | `sops -d <file>` | `sops -d` + build the affected host |
| Documentation / skills only | format gate | format gate |

## Gotchas

- Untracked files are invisible to flake commands. `git add` every new file
  before running any gate, `git add -N` is not enough for the flake source.
- `nix flake check --no-build` evaluates all four hosts but does not run the
  format check and does not build anything. Use it as the fast working gate.
- Builds do not decrypt secrets; a broken secrets file passes every build. Only
  `sops -d` (or activation) catches it.
- `nh os switch`, `nixos-rebuild switch`, and `nixos-rebuild test` are
  activation: they need sudo and change the running system. Run them only when
  the user explicitly asks.
- First build of a host can take 10–30+ minutes and many GB of downloads;
  subsequent builds are incremental. `freedompc` is cheap on this machine,
  `homepc`/`mdr018`/`demo` are not necessarily.
- `nix flake check` builds all four hosts. Reserve it for cross-cutting changes.

## Reporting results

Report every command executed and its outcome, plus any gate you skipped and
why. On failure include the relevant error and the file/symbol it points at.
