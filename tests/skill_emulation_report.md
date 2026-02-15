# Skill Emulation Report

This report simulates how GitHub Copilot Enterprise will process user prompts based on the current configuration of `SKILL.md` and the available documentation.

## Scenario 1: "Push code and run tests"

**User Prompt:** "I want to push my changes and run the CI tests."

### 1. Intent Recognition
Copilot scans `.github/skills/deploy-skill/SKILL.md` and matches the user's intent to the **Context** and **When to use this skill** sections:
-   *Match*: "What is the testing process?"
-   *Match*: "Push changes to production" (related context)

### 2. Context Retrieval
The skill explicitly instructs Copilot to consult specific documentation:
```markdown
- "What is the testing process?" (Consults `copilot-developer-skills/docs/confluence/quick-start-for-github-actions-testing/continuous-integration.md`)
```

### 3. Execution Logic
Copilot reads `continuous-integration.md` (verified to exist).
-   **Extracted Knowledge**: "You can create custom continuous integration (CI) workflows directly in your GitHub repository with GitHub Actions."
-   **Action**: Copilot will likely suggest:
    1.  Committing the code.
    2.  Pushing to the remote branch.
    3.  Explaining that a GitHub Actions workflow (defined in `.github/workflows/`) should automatically trigger.
    4.  It *won't* try to look for a legacy test script unless specifically asked, defaulting to the "Modern" CI path as described in the docs.

---

## Scenario 2: "Deploy to production"

**User Prompt:** "Deploy this application to production."

### 1. Intent Recognition
Copilot matches the prompt to:
-   `name: deploy-{{DEPLOY_ENV}}`
-   `description: Deploy the project to the {{DEPLOY_ENV}} environment...`

### 2. Constraint Check (Dual-Stack)
The skill enforces a **Constraint Check**:
> "The Agent must check which pipeline orchestration is active for this repository"

Copilot evaluates the two options defined in `SKILL.md`:

#### Option A: Modern Pipeline (GitHub Actions)
-   **Condition**: Is there a `.github/workflows/deploy.yml`?
-   **Action**: If yes, it uses the configured `{{RUNNER_SET}}` to trigger the workflow.

#### Option B: Legacy Pipeline (XL Release)
-   **Condition**: Does the repo rely on `deploy.sh` or legacy scripts?
-   **Action**:
    -   It identifies the need for **Connectivity** to `{{CONNECTIVITY}}` (e.g., `vmc2-gateway.internal`).
    -   It identifies the **Orchestrator** as `XL Release`.
    -   It consults `quick-start-for-github-actions-testing/cicd-runbook.md` for credentials/secrets.

### 3. Execution
-   **If Modern**: "I will trigger the deployment workflow on runner set `my-runner-set`."
-   **If Legacy**: "I see this is a legacy app. I will connect to `vmc2-gateway.internal` and trigger the release using the XL Release CLI. Please ensure `deploy_wrapper.sh` is configured."

## Conclusion
The `SKILL.md` file successfully directs Copilot to:
1.  **Differentiate** between testing (CI) and deployment (CD).
2.  **Retrieve** the correct, specific documentation for each task.
3.  **Handle** both Modern and Legacy infrastructure constraints dynamically.
