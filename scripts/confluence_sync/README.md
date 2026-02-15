# Confluence to Markdown Sync

This script downloads pages from Confluence and converts them to Markdown, preserving the hierarchy. It is designed to prepare documentation for GitHub Copilot Enterprise to index.

## Prerequisites

- Python 3.6+
- Confluence API Token (for Cloud) or Personal Access Token (for Server/DC)
- Network access to your Confluence instance

## Installation

Dependencies are vendored in the `vendor` directory, so you do not need to install anything if running in an isolated environment.

If you are setting this up for the first time or need to update dependencies:

1.  Ensure you have internet access.
2.  Run `./vendor_deps.sh` to install dependencies to the local `vendor` folder.
3.  Commit the `vendor` folder.

## Usage

### Option 1: Using the Wrapper Script (Recommended)

1.  Copy the example configuration:
    ```bash
    cp scripts/confluence_sync/confluence.conf.example scripts/confluence_sync/confluence.conf
    ```
2.  Edit `scripts/confluence_sync/confluence.conf` with your details.
3.  Run the sync:
    ```bash
    ./scripts/confluence_sync/sync_wrapper.sh
    ```

Alternatively, you can skip the config file and just export environment variables:
```bash
export CONFLUENCE_URL="..."
./scripts/confluence_sync/sync_wrapper.sh
```

### Option 2: Direct Python Execution

```bash
python3 scripts/confluence_sync/confluence_to_md.py \
  --url "https://your-domain.atlassian.net/wiki" \
  --username "your-email@example.com" \
  --token "your-api-token" \
  --page-id "123456789" \
  --out-dir "./docs/confluence" \
  --cloud # Remove this flag if using Confluence Server/Data Center
```

### Arguments

-   `--url`: Base URL of your Confluence instance.
-   `--username`: Your Confluence username (email for Cloud).
-   `--token`: API Token (Cloud) or Password/PAT (Server).
-   `--page-id`: The ID of the root page you want to download. The script will download this page and all its descendants.
-   `--out-dir`: Directory where Markdown files will be saved. Default: `./docs/confluence`.
-   `--cloud`: Flag to indicate Confluence Cloud. Omit for Server/DC.

## Output

The script generates Markdown files with YAML frontmatter.
-   **Leaf pages**: Saved as `Page-Title.md`.
-   **Parent pages**: Saved as `Page-Title/index.md` with children in the `Page-Title` directory.

The frontmatter includes:
-   `title`
-   `confluence_id`
-   `confluence_url`
-   `space`

This metadata helps Copilot understand the context and source of the information.
