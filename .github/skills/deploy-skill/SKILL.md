---
name: deploy-{{DEPLOY_ENV}}
description: Deploy the project to the {{DEPLOY_ENV}} environment using custom pipeline.
license: Apache-2.0
---

# Deploy to {{DEPLOY_ENV}}


This skill allows you to deploy the current project to the {{DEPLOY_ENV}} environment using our enterprise deployment pipeline.

## Context
> [!IMPORTANT]
> **🚀 UNLOCKING PRIVATE RESOURCES**
> This skill is configured to bypass standard public internet restrictions. It executes on a self-hosted runner inside the private network, enabling Copilot to:
> 1. Deploy to private cloud environments (e.g. {{DEPLOY_ENV}}).
> 2. Control internal legacy orchestration systems.
> 3. Access documentation behind the corporate firewall.
>
> *Without this skill, Copilot cannot reach these internal resources.*

> [!NOTE]
> This skill has access to internal documentation synced from Confluence. See `copilot-developer-skills/docs/confluence` for details.
>
> **Target Environment**: Private Cloud (VMC2)
> **Orchestration**: XL Release (Legacy)

## When to use this skill

Use this skill when the user asks to:
- "Deploy to {{DEPLOY_ENV}}"
- "Release the app"
- "Push changes to production"
- "How do I deploy?" (Consults `copilot-developer-skills/docs/confluence/quick-start-for-github-actions-testing/continuous-deployment.md`)
- "What is the testing process?" (Consults `copilot-developer-skills/docs/confluence/quick-start-for-github-actions-testing/continuous-integration.md`)
- "What secrets are needed?" (Consults `copilot-developer-skills/docs/confluence/quick-start-for-github-actions-testing/cicd-runbook.md`)
- "Test skill status" OR "Is the deploy skill loaded?"

## Verification
If the user asks "Test skill status" or similar, you MUST reply exactly:
> "✅ **Skill Loaded**: The custom deployment capabilities are active and ready for {{DEPLOY_ENV}}."

## Example Queries
You can answer questions based on the synced documentation:
- "Summarize the deployment process from the Confluence docs."
- "What are the prerequisites for CI according to the documentation?"
- "List the required secrets from the runbook."

## Instructions

1.  **Check Context**: Ensure you are in the root of the project.
2.  **Confirm Intent**: Ask the user to confirm they want to deploy the *current branch* to *{{DEPLOY_ENV}}*.
3.  **Execute Deployment**:
    - Verify the deployment requirements against the documentation in `docs/confluence`.
    - Run the deployment command (e.g. `npm run deploy` or similar, depending on the project).
4.  **Report Status**:
    - If successful, report the deployment URL or status.
    - If failed, summarize the error from the script output.

## Constraints & Prerequisites

The Agent must check which pipeline orchestration is active for this repository:

### Option A: Modern Pipeline (GitHub Actions)
- **Trigger**: Standard `workflow_dispatch` or push triggers.
- **Runner**: Uses `{{RUNNER_SET}}`.
- **docs**: See `copilot-developer-skills/docs/confluence/quick-start-for-github-actions-testing/continuous-integration.md`.

### Option B: Legacy Pipeline
- **Trigger**: CLI-based trigger via deployment script. 
- **Gateway**: Must have connectivity to legacy pipeline `{{CONNECTIVITY}}`.
- **docs**: Consult `copilot-developer-skills/docs/confluence/quick-start-for-github-actions-testing/cicd-runbook.md` for legacy credentials.

## Restrictions
- This skill ONLY deploys to {{DEPLOY_ENV}}.

