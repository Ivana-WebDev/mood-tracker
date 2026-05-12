#!/usr/bin/env python3
"""Generate wiki documentation from source code using GitHub Models API."""

import os, json, pathlib, urllib.request

MODEL = "gpt-4.1"
API_URL = "https://models.github.ai/inference/chat/completions"
OUTPUT_DIR = pathlib.Path("/tmp/wiki-pages")
ALLOWED_EXTS = {".ts", ".tsx", ".js", ".jsx", ".json", ".md", ".yml", ".yaml", ".css", ".scss"}
SKIP_DIRS = {"node_modules", ".git", "dist", "build", ".next", "coverage", "venv", "__pycache__", ".cache"}

# Priority files to always include
PRIORITY_FILES = {"package.json", "README.md", "tsconfig.json", ".env.example"}

PAGES = {
    "Home.md": "Create main Home wiki page: project overview, features, tech stack, repo layout, getting started, wiki index.",
    "Architecture.md": "Create Architecture page: app structure, routing, state management, entry points, data flow.",
    "Components.md": "Create Components page: major React components, hooks, context providers, styling.",
    "API-Reference.md": "Create API Reference page: API calls, endpoints, auth, env vars, integrations.",
    "Business-Logic.md": "Create Business Logic page: workflows, rules, algorithms, validations, permissions."
}

SYSTEM_PROMPT = """You are a senior software engineer writing GitHub Wiki documentation.
Rules:
- Only document what exists in the source code
- Never invent APIs, components, features, or types
- Use exact real names from the codebase
- Output raw markdown only
- Be concise but technically accurate"""

def call_model(system_prompt: str, user_prompt: str) -> str:
    payload = {
        "model": MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        "temperature": 0.2,
        "max_tokens": 4000
    }
    req = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
            "Content-Type": "application/json"
        },
        method="POST"
    )
    with urllib.request.urlopen(req, timeout=180) as resp:
        result = json.loads(resp.read().decode("utf-8"))
    return result["choices"][0]["message"]["content"]

def collect_source_files() -> str:
    priority = []
    regular = []
    
    for fp in sorted(pathlib.Path(".").rglob("*")):
        if not fp.is_file():
            continue
        if any(part in SKIP_DIRS for part in fp.parts):
            continue
        if fp.suffix not in ALLOWED_EXTS:
            continue
        if fp.stat().st_size > 50000:
            continue
        try:
            content = fp.read_text(encoding="utf-8", errors="replace")[:3000]
            entry = f"## FILE: {fp}\n```\n{content}\n```"
            if fp.name in PRIORITY_FILES:
                priority.append(entry)
            else:
                regular.append(entry)
        except Exception:
            pass
    
    # Take all priority files + limited regular files
    selected = priority + regular[:25]
    return "\n\n".join(selected)

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    source_context = collect_source_files()
    
    print(f"Source context size: {len(source_context)} chars")
    
    for filename, task in PAGES.items():
        print(f"Generating {filename}...")
        prompt = f"SOURCE FILES:\n{source_context}\n\nTASK:\n{task}"
        try:
            result = call_model(SYSTEM_PROMPT, prompt)
            (OUTPUT_DIR / filename).write_text(result, encoding="utf-8")
            print(f"✓ {filename} generated")
        except Exception as e:
            (OUTPUT_DIR / filename).write_text(f"# Generation failed\n\nError: {e}", encoding="utf-8")
            print(f"✗ Failed: {filename}: {e}")
    
    print("All wiki pages generated")

if __name__ == "__main__":
    main()
