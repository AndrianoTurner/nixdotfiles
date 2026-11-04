---
name: nixos-checks
description: Canonical read-only checks for this NixOS flake (format gate, eval gate, per-host builds, secrets validation). Use before reporting any change as done, when asked to verify changes, or as the checker/final gate.
---

# Checking changes in this repo

Run the gates from this file. Do not invent new commands or explore the tree to
figure out how to test something. All commands here are read-only; none of them
touch the running system. See `.pi/skills/nixos-repo/SKILL.md` for where
changes belong.

Load the shared `nix` skill before Nix operations (repository source:
`modules/home-manager/features/cli/pi-skills/nix/SKILL.md`). Never use `path:.`
or equivalent explicit path-flake workarounds, including through scripts or
children. Use the canonical Git-flake commands here.

Work from the repo root. `nh`, `nixos-rebuild`, and `sops` are on PATH;
`alejandra` is available only through `nix fmt` and `.#checks`.

## Gates

Format gate (seconds once evaluated):

```console
nix build .#checks.x86_64-linux.format
```

Fix only task-owned files with `nix fmt <file> ...`; use `nix fmt .` only when
formatting the whole flake will not change unrelated work.

Eval gate — current host, no build (fast):

```console
nix eval .#nixosConfigurations.<current>.config.system.build.toplevel.drvPath
```

Build gate — current host:

```console
nix build .#nixosConfigurations.<current>.config.system.build.toplevel --no-link
```

Package builds, when the change is in `pkgs/`:

```console
nix build .#<package>
```

Secrets gate:

```console
sops -d secrets/users/andriano.yaml > /dev/null
sudo sops -d secrets/system/shared.yaml > /dev/null
```

## Picking the gates

Determine the current hostname with `hostname` and use it in place of `<current>`.
Always verify against the host the agent is running on; other hosts'
configurations are out of scope unless the user names them. If the hostname does
not match a flake configuration, ask the user which host to check.

| Change | Minimum | Preferred |
| --- | --- | --- |
| One host file or host-specific setting | eval current host | build current host |
| Shared NixOS module (`common`, `desktop`, `optional`), HM feature/shared module | build current host | build current host + format gate |
| `overlays/`, `pkgs/`, `flake.nix`, `flake.lock` | build the package, then current host | build current host + format gate |
| Secrets | `sops -d <file>` | `sops -d` + build the affected host |
| Documentation / skills only | format gate | format gate |

## Gotchas

- Untracked files are invisible to flake commands. `git add` every new file
  before running any gate, `git add -N` is not enough for the flake source.
- `nix flake check` evaluates and builds every host. Do not run it by default;
  it is minutes of work for machines that are not this one.
- Builds do not decrypt secrets; a broken secrets file passes every build. Only
  `sops -d` (or activation) catches it.
- `nh os switch`, `nixos-rebuild switch`, and `nixos-rebuild test` are
  activation: they need sudo and change the running system. Run them only when
  the user explicitly asks.
- First build of the current host can take 10–30+ minutes and many GB of
  downloads; subsequent builds are incremental.

## Reporting results

Report every command executed and its outcome, plus any gate you skipped and
why. On failure include the relevant error and the file/symbol it points at.
