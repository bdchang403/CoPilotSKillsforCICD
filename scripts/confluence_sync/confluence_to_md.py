import os
import sys
import argparse
import re
from pathlib import Path
import json

# Add vendor directory to sys.path to use local dependencies
current_dir = Path(__file__).parent.resolve()
vendor_dir = current_dir / "vendor"
if vendor_dir.exists():
    sys.path.insert(0, str(vendor_dir))

try:
    import yaml
    import urllib.request
    import urllib.parse
    import urllib.error
    import base64
    from markdownify import markdownify as md
    from bs4 import BeautifulSoup
except ImportError as e:
    print(f"Error importing dependencies: {e}")
    print("Please run 'vendor_deps.sh' to install dependencies locally.")
    sys.exit(1)

class SimpleConfluenceClient:
    def __init__(self, url, username, token, cloud=False):
        self.base_url = url.rstrip('/')
        if cloud and self.base_url.endswith('/wiki'):
            self.base_url = self.base_url[:-5]
        
        # Encode Basic Auth credentials
        auth_str = f"{username}:{token}"
        auth_bytes = auth_str.encode('ascii')
        base64_bytes = base64.b64encode(auth_bytes)
        self.auth_header = f"Basic {base64_bytes.decode('ascii')}"
        
        self.cloud = cloud
        self.api_base = f"{self.base_url}/wiki/rest/api" if cloud else f"{self.base_url}/rest/api"

    def _get(self, path, params=None):
        url = f"{self.api_base}{path}"
        if params:
            query_string = urllib.parse.urlencode(params)
            url = f"{url}?{query_string}"
            
        req = urllib.request.Request(url)
        req.add_header("Authorization", self.auth_header)
        req.add_header("Accept", "application/json")
        
        try:
            with urllib.request.urlopen(req) as response:
                return json.loads(response.read().decode('utf-8'))
        except urllib.error.HTTPError as e:
            print(f"HTTP Error {e.code}: {e.reason} for URL {url}")
            # Try to print body for debugging
            try:
                print(e.read().decode('utf-8'))
            except:
                pass
            raise
        except urllib.error.URLError as e:
            print(f"URL Error: {e.reason} for URL {url}")
            raise

    def get_page_by_id(self, page_id, expand=None):
        params = {'expand': expand} if expand else {}
        return self._get(f"/content/{page_id}", params=params)

    def get_page_child_by_type(self, page_id, type='page', start=0, limit=100):
        params = {'start': start, 'limit': limit}
        return self._get(f"/content/{page_id}/child/{type}", params=params).get('results', [])

def clean_filename(title):
    """Sanitize title for use as a filename."""
    # Replace non-alphanumeric characters (except spaces, hyphens) with nothing
    cleaned = re.sub(r'[^\w\s-]', '', title)
    # Replace spaces with hyphens
    cleaned = re.sub(r'\s+', '-', cleaned)
    return cleaned.lower()

def clean_html(html_content):
    """Clean up HTML content before conversion."""
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Remove script and style tags
    for script in soup(["script", "style"]):
        script.decompose()
        
    return str(soup)

def process_page(confluence, page_id, output_dir, parent_path=Path(".")):
    """Recursively process a page and its children."""
    try:
        page = confluence.get_page_by_id(page_id, expand='body.storage,metadata,space')
    except Exception as e:
        print(f"Error fetching page {page_id}: {e}")
        return

    title = page['title']
    safe_title = clean_filename(title)
    
    # Check for children
    # Note: simplistic pagination handling here, assuming <100 children for now or just taking first page
    children = confluence.get_page_child_by_type(page_id, type='page')
    
    has_children = bool(children)
    
    if has_children:
        dir_path = output_dir / parent_path / safe_title
        dir_path.mkdir(parents=True, exist_ok=True)
        file_path = dir_path / "index.md"
        next_parent = parent_path / safe_title
    else:
        # No children, just a file in the parent dir
        dir_path = output_dir / parent_path
        dir_path.mkdir(parents=True, exist_ok=True)
        file_path = dir_path / f"{safe_title}.md"
        next_parent = None

    print(f"Processing: {title} -> {file_path}")

    # Convert content
    body_storage = page.get('body', {}).get('storage', {}).get('value', '')
    cleaned_html = clean_html(body_storage)
    markdown_content = md(cleaned_html, heading_style="ATX")
    
    # Add Frontmatter
    # Construct URL manually as _links might vary
    webui_link = page.get('_links', {}).get('webui', '')
    base_link = page.get('_links', {}).get('base', confluence.base_url)
    full_url = f"{base_link}{webui_link}"

    frontmatter = {
        'title': title,
        'confluence_id': page_id,
        'confluence_url': full_url,
        'space': page.get('space', {}).get('key', '')
    }
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write("---\n")
        yaml.dump(frontmatter, f, default_flow_style=False)
        f.write("---\n\n")
        
        # Add a helpful header for Copilot
        f.write(f"# {title}\n\n")
        f.write(f"> Source: [Confluence Page]({frontmatter['confluence_url']})\n\n")
        
        f.write(markdown_content)

    # Process children
    if has_children:
        for child in children:
            process_page(confluence, child['id'], output_dir, next_parent)

def main():
    parser = argparse.ArgumentParser(description="Sync Confluence pages to Markdown.")
    parser.add_argument("--url", required=True, help="Confluence URL")
    parser.add_argument("--username", required=True, help="Confluence Username")
    parser.add_argument("--token", required=True, help="Confluence API Token or Password")
    parser.add_argument("--page-id", required=True, help="Root Page ID to start syncing from")
    parser.add_argument("--out-dir", default="./docs/confluence", help="Output directory")
    parser.add_argument("--cloud", action="store_true", help="Use Confluence Cloud API (default: False)")
    
    args = parser.parse_args()
    
    confluence = SimpleConfluenceClient(
        url=args.url,
        username=args.username,
        token=args.token,
        cloud=args.cloud
    )
    
    out_path = Path(args.out_dir)
    out_path.mkdir(parents=True, exist_ok=True)
    
    process_page(confluence, args.page_id, out_path)
    print("Sync complete.")

if __name__ == "__main__":
    main()
