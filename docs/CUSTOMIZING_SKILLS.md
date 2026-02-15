# Customizing Your Copilot Deployment Skill

The `SKILL.md` file is the "brain" of your Copilot Skill. It tells GitHub Copilot **what** the skill does, **when** to use it, and **how** to execute it. This guide provides best practices and examples to help you create robust, agentic skills.

## 1. The Anatomy of SKILL.md

### Frontmatter (The YAML Header)
The frontmatter defines the unique identity of your skill.

```yaml
---
name: deploy-production       # Unique ID. Use lower-case-kebab-style.
description: Deploys code to the production environment.
license: Apache-2.0
---
```

**Good vs. Bad Frontmatter**

| Feature | ❌ **Not Good** (Ambiguous) | ✅ **Good** (Specific) | Why? |
| :--- | :--- | :--- | :--- |
| **Name** | `deploy` | `deploy-production-api` | Avoid collisions. Providing a unique name prevents Copilot from confusing it with other deploy skills. |
| **Description** | `Runs the deploy script.` | `Deploys the current backend branch to the production environment using blue-green deployment.` | Copilot uses the description to *choose* the skill. Specificity ensures it picks the right tool for the job. |

---

## 2. Triggering the Skill ("When to use")

The `## When to use this skill` section gives the AI examples of user prompts.

**Good vs. Bad Triggers**

| Feature | ❌ **Not Good** (Too Broad) | ✅ **Good** (Intent-Driven) | Why? |
| :--- | :--- | :--- | :--- |
| **Phrasing** | `- "Run script"` | `- "Deploy backend to prod"`<br>`- "Ship it!"`<br>`- "Release version"` | Captures the *intent* and specific jargon your team uses. |
| **Scope** | `- "Fix the code"` | `- "How do I deploy?"`<br>`- "What is the release process?"` | Should focus on the skill's specific domain (deployment), not general coding tasks. |

---

## 3. Defining Instructions

The `## Instructions` section is the logic the agent follows. You can make it simple or complex.

### Scenario A: Basic Execution

| ❌ **Not Good** (Vague) | ✅ **Good** (Explicit) |
| :--- | :--- |
| `1. Deploy the code.` | `1. Check if the user is on the 'main' branch.`<br>`2. If yes, run './scripts/deploy_wrapper.sh'`<br>`3. If no, warn the user.` |
| *Risk: Copilot might guess how to deploy.* | *Benefit: Deterministic behavior and safety checks.* |

### Scenario B: Handling User Input

You can teach Copilot to extract information from the user's prompt (e.g., "Deploy version v1.2").

| ❌ **Not Good** (Implicit) | ✅ **Good** (Structured Extraction) |
| :--- | :--- |
| `1. Run script with version.` | `1. Identify the version tag in the prompt (e.g. "v1.2").`<br>`2. If missing, ask: "Which version?"`<br>`3. Run: './deploy.sh --tag <VERSION>'` |
| *Risk: Copilot might pass an empty string or hallucinate a version.* | *Benefit: Ensures the script receives valid arguments.* |

---

## 4. Constraints & Safety (Context)

The `## Constraints` or `## Restrictions` section is critical for enterprise environments.

**Good vs. Bad Constraints**

| Feature | ❌ **Not Good** (Soft Rules) | ✅ **Good** (Hard Constraints) | Why? |
| :--- | :--- | :--- | :--- |
| **Day of Week** | `Don't deploy on Friday.` | `If today is Friday, REJECT the request with: "Deploys are frozen on Fridays."` | Giving Copilot a specific *action* (REJECT) is more effective than a passive rule. |
| **Branching** | `Use the main branch.` | `Check if current branch is 'main'. If not, STOP and ask for confirmation.` | Explicit control flow prevents accidents. |
| **Environment** | `Deploy to prod.` | `This skill ONLY targets 'production'. For staging, use 'deploy-staging'.` | Prevents cross-environment accidents. |

---

## 5. Context Injection (Documentation)

The most powerful feature is linking to internal documentation using `> [!NOTE]`.

**Good vs. Bad Context**

| ❌ **Not Good** (No Context) | ✅ **Good** (Grounded Context) |
| :--- | :--- |
| *(Empty)* | `> [!NOTE]`<br>`> Refer to 'docs/confluence/runbook.md' for required secrets.` |
| *Risk: Copilot hallucinates standard deployment steps.* | *Benefit: Copilot reads your actual runbook and knows exactly what your script needs.* |

---

## Summary Checklist

- [ ] **Unique Name**: Does `name` avoid conflict with other skills?
- [ ] **Specific Description**: Does `description` clearly state *what* and *where*?
- [ ] **Intent Examples**: Do you include team slang ("Ship it", "Nuke it")?
- [ ] **Explicit Steps**: Are instructions step-by-step logic, not vague goals?
- [ ] **Hard Constraints**: DO you explicitly tell Copilot when to STOP or REJECT?
- [ ] **Documentation**: Have you linked relevant docs for context?
