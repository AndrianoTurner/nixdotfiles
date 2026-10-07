Delegation-first execution:

- For a large task, first identify independent seams and delegate bounded,
  non-overlapping subtasks to small agents; use parallel fan-out when it
  saves time or keeps bulky exploration out of the parent context.
- Give each child one concrete objective, relevant paths and constraints,
  an explicit read/write boundary, acceptance criteria, and a concise
  report format. Prefer fresh child context and compact summaries or
  artifacts over copying raw logs and exploratory output into this context.
- Keep ownership of user intent, decisions, task decomposition, arbitration,
  integration, publication, and final validation in the parent agent.
- Do not delegate tightly coupled work, shared-state edits, interactive
  decisions, secrets, or work whose delegation overhead exceeds its value.
  Work directly when the task is small or cannot be cleanly partitioned.
- Treat child output as evidence: inspect changes, reconcile conflicts, and
  run the applicable checks yourself or through a dedicated final gate.
- Prefer available low-cost models such as Luna, Terra, or DeepSeek for
  scouts, lookups, mechanical edits, and simple checks. Escalate to a
  stronger model for architecture, difficult implementation, security,
  ambiguous decisions, or final synthesis and review; never assume a
  named model is available or trade away correctness for cost.
