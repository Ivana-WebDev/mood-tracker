#!/usr/bin/env python3
"""Incremental wiki update based on git diff."""

import os, json, subprocess, pathlib, time, sys
import urllib.request, urllib.error

ANTHROPIC_API_KEY = os.environ["ANTHROPIC_API_KEY"]
MODEL = "claude-sonnet-4-20250514"
OUTPUT_DIR = pathlib.Path("/tmp/wiki-pages")

SKIP_DIRS = {"node_modules", ".git", "dist", "build", ".next", "coverage", "venv", "__pycache__"}

# Map file patterns to wiki pages that should be updated
PAGE_TRIGGERS = {
    "Home.md": ["package.json", "README", "tsconfig"],
    "Architecture.md": ["src/app", "src/pages", "src/routes", "src/index", "src/main"],
    "Components.md": ["components/", "hooks/", ".tsx", ".jsx"],
    "API-Reference.md": ["api/", "services/", "fetch", "axios", "http"],
    "Business-Logic.md": ["utils/", "helpers/", "lib/", "logic/", "services/"],
}

def call_claude(system_prompt: str, user_prompt: str) -> str:
    payload = {
        "model": MODEL,
        "max_tokens": 4096,
        "system": system_prompt,
        "messages": [{"role": "user", "content": user_prompt}],
    }
    req = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=json.dumps(payload).encode(),
        headers={
            "x-api-key": ANTHROPIC_API_KEY,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        },
        method="POST",
    )
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                return json.loads(resp.read())["content"][0]["text"]
        except urllib.error.HTTPError as e:
            print(f"HTTP {e.code}: {e.read().decode()}", file=sys.stderr)
            if e.code in {429, 529} and attempt < 2:
                time.sleep(30 * (attempt + 1))
            else:
                raise
    return ""

def get_changed_files() -> list[str]:
    """Get files changed in the last commit."""
    result = subprocess.run(
        ["git", "diff", "--name-only", "HEAD~1", "HEAD"],
        capture_output=True, text=True
    )
    return [f.strip() for f in result.stdout.strip().split("\n") if f.strip()]

def get_diff_content() -> str:
    """Get the actual diff content."""
    result = subprocess.run(
        ["git", "diff", "HEAD~1", "HEAD", "--", "src/", "package.json"],
        capture_output=True, text=True
    )
    # Truncate if too large
    diff = result.stdout[:15000]
    if len(result.stdout) > 15000:
        diff += "\n... [diff truncated]"
    return diff

def read_file(path: str, max_chars: int = 3000) -> str:
    try:
        return pathlib.Path(path).read_text(encoding="utf-8", errors="replace")[:max_chars]
    except Exception:
        return ""

def find_imports(file_path: str) -> list[str]:
    """Find local imports in a file."""
    content = read_file(file_path, 5000)
    imports = []
    for line in content.split("\n"):
        if "from './" in line or "from '../" in line or 'from "./' in line or 'from "../' in line:
            # Extract the path
            start = line.find("from") + 5
            path_part = line[start:].strip().strip("'\"").strip(";")
            imports.append(path_part)
    return imports

def determine_pages_to_update(changed_files: list[str]) -> list[str]:
    """Determine which wiki pages need updating based on changed files."""
    pages = set()
    for changed in changed_files:
        for page, triggers in PAGE_TRIGGERS.items():
            if any(trigger in changed for trigger in triggers):
                pages.add(page)
    
    # If significant changes, always update Home
    if len(changed_files) > 5 or any("package.json" in f for f in changed_files):
        pages.add("Home.md")
    
    return list(pages)

def gather_context(changed_files: list[str]) -> str:
    """Gather source context: changed files + their imports."""
    context_parts = []
    seen = set()
    
    # Always include package.json and tsconfig for context
    for cfg in ["package.json", "tsconfig.json"]:
        if pathlib.Path(cfg).exists():
            content = read_file(cfg, 2000)
            context_parts.append(f"## CONFIG: {cfg}\n```json\n{content}\n```")
    
    # Add changed files and their imports
    for fp in changed_files[:20]:  # Limit to 20 changed files
        if not pathlib.Path(fp).exists():
            continue
        if any(skip in fp for skip in SKIP_DIRS):
            continue
        if fp in seen:
            continue
        seen.add(fp)
        
        content = read_file(fp, 3000)
        ext = pathlib.Path(fp).suffix
        context_parts.append(f"## CHANGED: {fp}\n```{ext[1:]}\n{content}\n```")
        
        # Add imported files for context
        for imp in find_imports(fp)[:5]:
            # Resolve relative import
            base = pathlib.Path(fp).parent
            for ext in [".ts", ".tsx", ".js", ".jsx", "/index.ts", "/index.tsx"]:
                imp_path = base / (imp + ext)
                if imp_path.exists() and str(imp_path) not in seen:
                    seen.add(str(imp_path))
                    imp_content = read_file(str(imp_path), 2000)
                    context_parts.append(f"## RELATED: {imp_path}\n```\n{imp_content}\n```")
                    break
    
    return "\n\n".join(context_parts)

def read_existing_wiki(page: str) -> str:
    """Read existing wiki page if it exists."""
    wiki_path = pathlib.Path("wiki-repo") / page
    if wiki_path.exists():
        return wiki_path.read_text(encoding="utf-8", errors="replace")
    return ""

PAGE_PROMPTS = {
    "Home.md": "Update the Home wiki page based on the changes. Keep existing structure but update relevant sections.",
    "Architecture.md": "Update the Architecture wiki page based on the changes. Focus on any structural changes.",
    "Components.md": "Update the Components wiki page. Add/update documentation for changed components.",
    "API-Reference.md": "Update the API Reference wiki page. Document any new/changed API calls or endpoints.",
    "Business-Logic.md": "Update the Business Logic wiki page. Document any new/changed business logic.",
}

SYSTEM_PROMPT = """You are updating wiki documentation based on recent code changes.

Rules:
- Preserve existing documentation structure and content where unchanged
- Only update sections affected by the diff
- Use real names from the codebase
- Keep documentation accurate to the actual code
- Output complete updated markdown page
- Be concise but technically accurate"""

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    changed_files = get_changed_files()
    print(f"Changed files: {changed_files}")
    
    if not changed_files:
        print("No changes detected")
        return
    
    pages_to_update = determine_pages_to_update(changed_files)
    print(f"Pages to update: {pages_to_update}")
    
    if not pages_to_update:
        print("No wiki pages need updating based on changes")
        return
    
    diff_content = get_diff_content()
    source_context = gather_context(changed_files)
    
    print(f"Context size: {len(source_context)} chars")
    print(f"Diff size: {len(diff_content)} chars")
    
    for page in pages_to_update:
        print(f"\nUpdating {page}...")
        
        existing = read_existing_wiki(page)
        task = PAGE_PROMPTS.get(page, "Update this wiki page based on the changes.")
        
        prompt = f"""EXISTING WIKI PAGE:
```markdown
{existing[:4000] if existing else "(No existing page)"}
