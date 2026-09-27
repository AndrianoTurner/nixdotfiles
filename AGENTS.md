# Agent guide

NixOS flake for the hosts `freedompc`, `homepc`, `mdr018`, and the secret-free
QEMU demo. Before changing anything, read:

- `.pi/skills/nixos-repo/SKILL.md` — layout, conventions, where a change belongs
- `.pi/skills/nixos-checks/SKILL.md` — canonical verification commands

Fast gates (run from the repo root):

```console
nix flake check --no-build                     # evaluate all hosts, no builds
nix build .#checks.x86_64-linux.format         # formatting gate (fix: nix fmt .)
```

Rules:

- Build and check only. Never run `nh os switch` / `nixos-rebuild switch|test`
  (activation) unless the user explicitly asks.
- `git add` new files before running flake commands; untracked files are
  invisible to them.
- The demo configuration stays secret-free: never import sops there.
- Never print, diff, or commit decrypted secrets; edit them with `sops` only.
