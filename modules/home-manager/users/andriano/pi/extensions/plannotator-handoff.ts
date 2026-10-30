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
let pendingModel: { provider: string; id: string } | undefined;

function dispatchNext() {
  if (dispatching || !activePi || queue.length === 0) return;
  dispatching = true;
  activePi.sendUserMessage(`/${NEW_SESSION_COMMAND}`, {
    expandPromptTemplates: true,
  });
}

export default function (pi: ExtensionAPI) {
  activePi = pi;

  pi.on("before_agent_start", (event, ctx) => {
    const sections = event.systemPromptOptions.sections;
    if (!pi.getActiveTools().includes("plannotator_submit_plan")) {
      delete sections.plannotator_implementation_model;
      return;
    }
    sections.plannotator_implementation_model = [
      "Before submitting a Plannotator plan, recommend an implementation model based on the plan's complexity and risk.",
      "Include exactly one line in the plan: Implementation model: provider/model-id",
      "Follow it with a short explanation. Prefer a lower-cost model for routine work; prioritize capability for architecture, difficult implementation, or security. Do not invent capabilities or prices.",
      "Choose only from these currently available models:",
      ...ctx.modelRegistry.getAvailable().map(
        (model) => `${model.provider}/${model.id} (${model.name})`,
      ),
      "The user will confirm or override this recommendation before implementation.",
    ].join("\n");
  });

  pi.on("session_start", async (_event, ctx) => {
    // Apply settings through the replacement session's fresh extension instance;
    // the old pi is stale after newSession(). Set the model before thinking.
    const modelRef = pendingModel;
    const thinkingLevel = pendingThinkingLevel;
    pendingModel = undefined;
    pendingThinkingLevel = undefined;
    if (modelRef) {
      const model = ctx.modelRegistry.find(modelRef.provider, modelRef.id);
      if (!model || !(await pi.setModel(model))) {
        ctx.ui.notify(
          "Could not select the implementation model. The plan will not start.",
          "error",
        );
      }
    }
    if (thinkingLevel) pi.setThinkingLevel(thinkingLevel);
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

        const models = ctx.modelRegistry.getAvailable();
        const recommendation = handoff.planContent.match(
          /^Implementation model:[ \t]*`?([^`\r\n]+?)`?[ \t]*$/im,
        )?.[1];
        const recommendedModel = models.find(
          (model) => `${model.provider}/${model.id}` === recommendation,
        );
        const currentModel = ctx.model;
        const inheritModel = currentModel
          ? `Inherit current (${currentModel.provider}/${currentModel.id})`
          : "Inherit current model";
        const modelChoices = models.map((model) => ({
          model,
          label: `${model.provider}/${model.id}${model === recommendedModel ? " (Recommended)" : ""}`,
        }));
        const recommendedChoice = modelChoices.find(
          ({ model }) => model === recommendedModel,
        );
        if (recommendation && !recommendedModel) {
          ctx.ui.notify(
            "The recommended implementation model is unavailable. Choose another model.",
            "warning",
          );
        }
        const modelChoice = await ctx.ui.select("Model for implementation", [
          ...(recommendedChoice ? [recommendedChoice.label] : []),
          inheritModel,
          ...modelChoices
            .filter((choice) => choice !== recommendedChoice)
            .map(({ label }) => label),
        ]);
        if (!modelChoice) {
          ctx.ui.notify("Plannotator handoff cancelled.", "info");
          return;
        }
        const selectedModel =
          modelChoices.find(({ label }) => label === modelChoice)?.model ?? currentModel;

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
        pendingModel = selectedModel
          ? { provider: selectedModel.provider, id: selectedModel.id }
          : undefined;
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
            if (
              selectedModel && (
                replacementCtx.model?.provider !== selectedModel.provider ||
                replacementCtx.model?.id !== selectedModel.id
              )
            ) {
              replacementCtx.ui.notify(
                "Implementation model was not applied. The plan has not started.",
                "error",
              );
              return;
            }
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
        if (!replaced) {
          pendingThinkingLevel = undefined;
          pendingModel = undefined;
        }
        // Reset before draining so a queued handoff is picked up even if this
        // one was cancelled or failed. activePi points at the replacement
        // session's extension instance when a replacement happened.
        dispatching = false;
        dispatchNext();
      }
    },
  });
}
