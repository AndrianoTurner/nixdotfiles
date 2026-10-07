import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { ThinkingLevel } from "@earendil-works/pi-agent-core";

const PLANNOTATOR_PLAN_APPROVED_CHANNEL = "plannotator:plan-approved";
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

export default function (pi: ExtensionAPI) {
  let pending: PlannotatorPlanApprovedEvent | undefined;

  pi.events.on(PLANNOTATOR_PLAN_APPROVED_CHANNEL, (event) => {
    pending = event as PlannotatorPlanApprovedEvent;
    pi.sendUserMessage("/plannotator-new-session", {
      expandPromptTemplates: true,
    });
  });

  pi.registerCommand("plannotator-new-session", {
    description: "Execute an approved Plannotator plan in a clean session",
    handler: async (_args, ctx) => {
      const handoff = pending;
      pending = undefined;

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
      const thinkingLevel =
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
          replacementCtx.setThinkingLevel(thinkingLevel);
          replacementCtx.ui.notify(
            "Executing the approved plan in a clean session.",
            "info",
          );
          await replacementCtx.sendUserMessage(prompt, {
            expandPromptTemplates: false,
          });
        },
      });

      if (result.cancelled)
        ctx.ui.notify("Plannotator handoff cancelled.", "info");
    },
  });
}
