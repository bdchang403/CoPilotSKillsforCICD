# copilot-developer-skills

This repository provides a template for creating a **GitHub Copilot Skill** that enables AI agents to deploy applications using a custom enterprise pipeline on self-hosted runners.

## Overview

Deploying to enterprise environments often requires specific network access, VPNs, or custom CLI tools available only on internal servers. This skill bridges the gap by:

1.  Defining a **Copilot Skill** that understands "deploy" intents.
2.  Delegating the execution to a **Self-Hosted Runner** secure inside your network.
3.  Wrapping your existing deployment scripts with an Agent-friendly interface.

## Why is `SKILL.md` Required?

The `.github/skills/deploy-skill/SKILL.md` file is the **brain** of your custom skill. Without it, GitHub Copilot is just a general-purpose coding assistant. With it, Copilot becomes a specialized agent capable of navigating your specific enterprise infrastructure.

### How it Works
1.  **Intent Recognition**: When you type "Deploy to production", Copilot scans the `SKILL.md` files in your repository. It matches your request against the `description` and `example queries` defined in the skill.
2.  **Context Injection**: The skill instructs Copilot to specifically read your internal documentation (e.g., `copilot-developer-skills/docs/confluence/`). This "grounds" the AI, preventing hallucinations and ensuring it knows *exactly* which script to run (e.g., `deploy_wrapper.sh`) and what constraints to respect (e.g., checking VMC2 gateway connectivity).
3.  **Execution on Custom Runners**:
    -   **Modern Pipeline**: The skill triggers a workflow on your **Self-Hosted Runner (ARC)**. This runner sits inside your private network (VMC2), allowing it to access internal resources that GitHub.com cannot reach directly.
    -   **Legacy Pipeline**: The skill instructs the runner to execute the **XL Release CLI**. Because the runner is inside your network, it can authenticate with the legacy orchestrator and trigger the release, bridging the gap between modern AI and legacy operations.

## Repository Structure

```
copilot-developer-skills/
├── setup.sh                # Interactive installer script
├── .github/skills/         # The skill definition (SKILL.md)
├── scripts/                # The wrapper script (deploy_wrapper.sh)
└── config/                 # Configuration templates
```

## Installation

You can install this skill into any existing repository where you want to enable Copilot-driven deployments.

### Option 1: Automated Installation (Recommended)

1.  **Clone this repository** locally.
2.  **Navigate to your target project**:
    ```bash
    cd my-app-repo
    ```
3.  **Run the installer**:
    ```bash
    ../copilot-developer-skills/setup.sh
    ```
4.  **Follow the interactive prompts** to configure your runner set and environment.

The installer will:
-   Create a `copilot-developer-skills/` directory containing scripts and docs.
-   Install the skill definition to `.github/skills/`.
-   Generate a local configuration file at `copilot-developer-skills/config/skill.conf`.
-   Add the config file to your `.gitignore`.

### Option 2: Manual Installation

If you prefer to configure everything yourself:

1.  **Copy the Skill Definition**:
    -   Copy `.github/skills/deploy-skill/` to `.github/skills/deploy-skill/` in your repo.
2.  **Copy Assets**:
    -   Create a directory named `copilot-developer-skills/` in your repo root.
    -   Copy `scripts/`, `config/`, and `docs/` from this repo into `copilot-developer-skills/`.
3.  **Configure the Skill**:
    -   Open `.github/skills/deploy-skill/SKILL.md`.
    -   Replace `{{RUNNER_SET}}` with your runner scale set name.
    -   Replace `{{DEPLOY_ENV}}` with your target environment (e.g., `production`).
4.  **Create Configuration**:
    -   Copy `copilot-developer-skills/config/skill.conf.example` to `copilot-developer-skills/config/skill.conf`.
    -   Edit `skill.conf` to set your `RUNNER_SET`, `DEPLOY_TARGET`, and `REAL_DEPLOY_SCRIPT` path.
5.  **Update .gitignore**:
    -   Add `copilot-developer-skills/config/skill.conf` to your `.gitignore` file.

## Usage

Once installed, committed, and pushed to your default branch:

1.  Open GitHub Copilot Chat (in VS Code or on GitHub.com).
2.  Ask: **"Deploy this application to production"**
3.  The Agent will:
    - Recognize the intent via `deployment-skill`.
    - Confirm the action.
    - Trigger the specific GitHub Actions workflow (or runner job) defined by the skill.
    - Report the result.

## Customization

- **Skill Definition**: Edit `.github/skills/deploy-skill/SKILL.md` to refine the instructions or instructions.
- **Wrapper Logic**: Edit `scripts/deploy_wrapper.sh` to add logging, notifications, or complex logic.
- **Configuration**: Edit `config/skill.conf` to change the target environment or runner set.

> [!TIP]
> For detailed guidance on writing powerful skills, establishing constraints, and handling user input, see [docs/CUSTOMIZING_SKILLS.md](docs/CUSTOMIZING_SKILLS.md).

## Troubleshooting

Is Copilot ignoring your skill? Follow these steps to verify it is working correctly.

### 1. Verify Skill Detection
In GitHub Copilot Chat, ask:
> **"What skills are available in this repository?"**
Copilot should list `deploy-production` (or your configured name) in the response. If it says "I don't see any skills", verify that:
-   The file is at `.github/skills/deploy-skill/SKILL.md` (exactly).
-   You have committed and **pushed** the file to the default branch (usually `main`). Copilot often reads from the remote default branch.

### 2. Verify Runner Connectivity
If Copilot accepts the command but the deployment hangs:
-   **Check GitHub Actions Tab**: See if a workflow was triggered.
-   **Check ARC Logs**: If the workflow is queued, your Self-Hosted Runner implementation might be offline or mismatched.
    -   Ensure the `runs-on` label in the workflow matches your `RUNNER_SET` config.
    -   Ensure your runner has outbound connectivity to GitHub.

### 3. Verify Legacy/VMC2 Access
If the job fails during execution:
-   **XL Release**: Check if the runner can reach the XL Release server.
-   **VMC2 Gateway**: Check if the runner can resolve the `{{VMC2_GATEWAY}}` address defined in your `setup.sh`.

## Technical Requirements

To successfully use this skill, your project must meet the following criteria:

### 1. Existing CI/CD Workflows
The skill does not magically deploy code; it triggers *existing* automation.
-   **For Modern Pipelines**: Your repository must already contain valid GitHub Actions workflow files (e.g., `.github/workflows/ci.yml`, `.github/workflows/deploy.yml`).
-   **For Legacy Pipelines**: Your repository must contain the necessary deployment scripts (e.g., `scripts/deploy.sh`) that the agent can execute.

### 2. Strict Skill Location
GitHub Copilot Enterprise looks for skills in a *very specific* location.
-   **File Path**: The skill definition file **MUST** be located at `.github/skills/deploy-skill/SKILL.md`.
-   **Visibility**: If the file is anywhere else (e.g., root, `docs/`), Copilot **will not see it**.
-   **Default Branch**: The file must be committed and pushed to your repository's default branch (usually `main` or `master`).

## Prerequisites

- **GitHub Enterprise Cloud** with Copilot Enterprise enabled.
- **Self-Hosted Runners** set up via Actions Runner Controller (ARC).
