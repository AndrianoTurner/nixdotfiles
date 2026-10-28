# Agent guide

NixOS flake for the hosts `freedompc`, `homepc`, `mdr018`, and `chodum`.
Before changing anything, read:

- `.pi/skills/nixos-repo/SKILL.md` — layout, conventions, where a change belongs
- `.pi/skills/nixos-checks/SKILL.md` — canonical verification commands

Fast gates (run from the repo root):

```console
nix build .#checks.x86_64-linux.format         # formatting gate (fix: nix fmt .)
nix build .#nixosConfigurations.<current>.config.system.build.toplevel --no-link
```

Rules:

- Build and check only the host you are on (`homepc`), never the other hosts'
  `nixosConfigurations`; that costs minutes and proves nothing about this
  machine. Only the user's explicit request may widen the scope.
- Build and check only. Never run `nh os switch` / `nixos-rebuild switch|test`
  (activation) unless the user explicitly asks.
- `git add` new files before running flake commands; untracked files are
  invisible to them.
- Never print, diff, or commit decrypted secrets; edit them with `sops` only.
