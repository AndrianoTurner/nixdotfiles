# Agent guide

This repository declaratively configures NixOS and Home Manager for
`freedompc`, `homepc`, `mdr018`, and `chodum`. System modules live under
`modules/nixos`, shared CLI/desktop features under `modules/home-manager/features`,
and personal settings under `modules/home-manager/users`. Host composition lives
in `hosts/<host>`; `flake.nix` wires the inputs and outputs.

Keep changes in the owning module and use explicit imports. Before changing
anything, read:

- `.pi/skills/nixos-repo/SKILL.md` — layout, conventions, where a change belongs
- `.pi/skills/nixos-checks/SKILL.md` — canonical verification commands
- The shared `nix` skill before Nix operations (source:
  `modules/home-manager/features/cli/pi-skills/nix/SKILL.md`)

Fast gates (run from the repo root):

```console
nix build .#checks.x86_64-linux.format         # formatting gate (fix: nix fmt .)
nix build .#nixosConfigurations.<current>.config.system.build.toplevel --no-link
```

Rules:

- Never use `path:.` or an equivalent explicit path-flake workaround for this
  checkout, including through scripts, nested commands, or delegated children.
  Use the canonical Git-flake commands above; do not bypass missing Git inputs.
- Build and check only the host you are on, never the other hosts'
  `nixosConfigurations`; that costs minutes and proves nothing about this
  machine. Only the user's explicit request may widen the scope.
- Build and check only. Never run `nh os switch` / `nixos-rebuild switch|test`
  (activation) unless the user explicitly asks.
- `git add` new files before running flake commands; untracked files are
  invisible to them.
- Never print, diff, or commit decrypted secrets; edit them with `sops` only.
