# Operational Runbook: CI/CD Pipeline

> [!IMPORTANT]
> This runbook contains the specific technical details required to execute the CI/CD pipelines described in the [Continuous Integration](./continuous-integration.md) and [Continuous Deployment](./continuous-deployment.md) documentation.

## Workflows

### 1. Continuous Integration (CI)
- **Workflow Location**: `.github/workflows/*.yml` (Search for build/test steps)
- **Triggers**:
  - `push` to `main`
  - `pull_request` targeting `main`
- **Primary Jobs**:
  - `lint`: Checks code style.
  - `test`: Runs unit tests.
  - `build`: Builds the application artifact.

### 2. Continuous Deployment (CD)
- **Workflow File**: `.github/workflows/cd.yml` (Example)
- **Triggers**:
  - `release` (published)
  - `workflow_dispatch` (manual trigger)
- **Environments**:
  - `staging`: Auto-deployed on push to `staging` branch.
  - `production`: Requires manual approval or release tag.

## Secrets & Configuration

The following secrets must be present in the repository settings for the pipelines to function:

| Secret Name | Description | Used By |
|-------------|-------------|---------|
| `AZURE_CREDENTIALS` | JSON credentials for Azure login | CD Workflow |
| `NPM_TOKEN` | Token for publishing packages | CI/CD |
| `DATABASE_URL` | Integration test database connection | CI Workflow |

## Environment Variables
- `NODE_ENV`: Set to `production` during build.
- `REGION`: `us-east-1` (default deployment region).

## Runner Requirements
- **Self-Hosted Runners**: Required for production deployment. Labels: `self-hosted`, `linux`, `x64`.
- **GitHub-Hosted Runners**: Used for CI tests (`ubuntu-latest`).
