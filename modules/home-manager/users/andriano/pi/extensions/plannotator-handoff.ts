import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { ThinkingLevel } from "@earendil-works/pi-agent-core";

const PLANNOTATOR_PLAN_APPROVED_CHANNEL = "plannotator:plan-approved";
const NEW_SESSION_COMMAND = "plannotator-new-session";
const THINKING_LEVELS: ThinkingLevel[] = [
  "off",
  "minimal",
  "low",
  "medium",
  "high",
  "xhigh",
  "max",
];

type PlannotatorPlanApprovedEvent = {
  cwd: string;
  planFilePath: string;
  planContent: string;
  feedback?: string;
};

// This module's top-level state survives session replacement: Pi re-runs the
// extension factory for the replacement session (the old `pi` becomes stale),
// so anything that must cross the boundary lives here rather than in the
// factory closure.
const queue: PlannotatorPlanApprovedEvent[] = [];
let activePi: ExtensionAPI | undefined;
let dispatching = false;
let pendingThinkingLevel: ThinkingLevel | undefined;

function dispatchNext() {
  if (dispatching || !activePi || queue.length === 0) return;
  dispatching = true;
  activePi.sendUserMessage(`/${NEW_SESSION_COMMAND}`, {
    expandPromptTemplates: true,
  });
}

export default function (pi: ExtensionAPI) {
  activePi = pi;

  pi.on("session_start", () => {
    // Runs in the replacement session's fresh extension instance. This is the
    // only place pi.setThinkingLevel is valid after newSession(); the context
    // passed to withSession has no setter and the old pi is stale.
    if (pendingThinkingLevel) {
      pi.setThinkingLevel(pendingThinkingLevel);
      pendingThinkingLevel = undefined;
    }
    // A handoff may have queued while the previous session was being replaced.
    dispatching = false;
    dispatchNext();
  });

  pi.events.on(PLANNOTATOR_PLAN_APPROVED_CHANNEL, (event) => {
    queue.push(event as PlannotatorPlanApprovedEvent);
    dispatchNext();
  });

  pi.registerCommand(NEW_SESSION_COMMAND, {
    description: "Execute an approved Plannotator plan in a clean session",
    handler: async (_args, ctx) => {
      const handoff = queue.shift();
      let replaced = false;
      try {
        if (!handoff) return;
        if (ctx.mode !== "tui") {
          ctx.ui.notify(
            "Plannotator handoff requires interactive mode.",
            "error",
          );
          return;
        }

        const currentThinkingLevel = pi.getThinkingLevel();
        const inherit = `Inherit current (${currentThinkingLevel})`;
        const choice = await ctx.ui.select(
          "Thinking level for the replacement session",
          [inherit, ...THINKING_LEVELS],
        );
        if (!choice) {
          ctx.ui.notify("Plannotator handoff cancelled.", "info");
          return;
        }
        pendingThinkingLevel =
          choice === inherit ? currentThinkingLevel : (choice as ThinkingLevel);

        const prompt = [
          "You are in a clean session. Execute the approved plan below.",
          "Working directory: " + handoff.cwd,
          "Plan file: " + handoff.planFilePath,
          "Read the plan file first, then implement every unchecked step and run its verification.",
          handoff.feedback ? "Reviewer notes:\n" + handoff.feedback : "",
          "Approved plan:\n\n" + handoff.planContent,
        ]
          .filter(Boolean)
          .join("\n\n");

        const result = await ctx.newSession({
          parentSession: ctx.sessionManager.getSessionFile(),
          withSession: async (replacementCtx) => {
            replacementCtx.ui.notify(
              "Executing the approved plan in a clean session.",
              "info",
            );
            await replacementCtx.sendUserMessage(prompt, {
              expandPromptTemplates: false,
            });
          },
        });
        replaced = !result.cancelled;

        if (result.cancelled)
          ctx.ui.notify("Plannotator handoff cancelled.", "info");
      } finally {
        if (!replaced) pendingThinkingLevel = undefined;
        // Reset before draining so a queued handoff is picked up even if this
        // one was cancelled or failed. activePi points at the replacement
        // session's extension instance when a replacement happened.
        dispatching = false;
        dispatchNext();
      }
    },
  });
}
