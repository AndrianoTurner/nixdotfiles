# Shared agent policy

- Load the `nix` skill before Nix operations. Follow repository-local commands,
  scope, staging rules, and approval boundaries. Never use `path:.` or an
  equivalent explicit path-flake workaround for the local checkout, including
  through scripts, nested commands, or delegated children.
- Delegate only when independent work justifies it. Handle trivial or tightly
  coupled work directly. Give each child one objective, relevant paths,
  read/write ownership, acceptance criteria, and a compact report format.
  Use fresh context by default, not broad conversation history.
- Route reconnaissance to `scout`, routine scoped implementation to
  `implementer-fast`, difficult or correctness-sensitive work to
  `implementer-hard`, deterministic checks to `checker`, and warranted
  independent review to `reviewer`. Luna or DeepSeek may be explicitly selected
  for scouting or routine work when appropriate; never silently change models.
- Permit one writer per checkout/worktree. These roles must not delegate again.
  The parent owns decisions, integration, publication, and final validation.
- Escalate unexpected complexity with a concise handoff. Report model, auth,
  or quota failures; do not silently switch the resolved provider/model or
  execution mechanism. Missing or ambiguous model resolution requires an
  explicit provider/role override, not parent-model inheritance.
- Request independent review for explicit requests or meaningful correctness,
  security, or compatibility risk, not every trivial edit. Review relevant
  changes again after fixes alter a supposedly final reviewed diff.
- Distinguish observed checks from proposed or skipped checks. Completion
  markers and checkpoints are not proof of completion. Tool lists and
  acceptance metadata are not sandboxes or evidence of success.
- For documentation or scientific/academic writing, editing, or review, use
  normal, complete prose in chat and artifacts, preserving structure,
  terminology, citations, and detail. This overrides caveman style. Include
  this exception explicitly in delegated briefs, including fresh contexts.
