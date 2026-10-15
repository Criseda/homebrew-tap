#!/usr/bin/env python3
"""Opens a pull request for every package in this tap with a newer release.

livecheck finds the newer versions. Casks are bumped with
`brew bump-cask-pr --write-only`. Formulae are rewritten here instead,
because `brew bump-formula-pr` cannot bump a formula with a URL per OS
and architecture (like netscanner): every url line has its version
replaced, and the sha256 line after it gets the new download's hash.

Each bump goes to its own branch, bump/<name>-<version>; a package whose
branch already exists is skipped, so an open bump PR is not opened
twice. Runs in CI (.github/workflows/bump.yml) and works locally too,
with --dry-run to only print what is outdated.
"""

import argparse
import hashlib
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

TAP = "criseda/tap"
ROOT = Path(__file__).resolve().parents[2]


def run(*args: str, capture: bool = False) -> str:
    result = subprocess.run(args, cwd=ROOT, check=True, text=True, capture_output=capture)
    return result.stdout if capture else ""


def outdated() -> list[dict]:
    output = run("brew", "livecheck", "--tap", TAP, "--json", "--newer-only", "--quiet", capture=True)
    return json.loads(output) if output.strip() else []


def sha256_of(url: str) -> str:
    digest = hashlib.sha256()
    with urllib.request.urlopen(url) as response:
        for chunk in iter(lambda: response.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def bump_formula(name: str, current: str, latest: str) -> None:
    path = ROOT / "Formula" / f"{name}.rb"
    lines = path.read_text().splitlines(keepends=True)
    url_pattern = re.compile(r'^(\s*)url "([^"]+)"')
    sha_pattern = re.compile(r'^(\s*)sha256 "[0-9a-f]{64}"')
    changed = 0
    for index, line in enumerate(lines):
        match = url_pattern.match(line)
        if not match or current not in match.group(2):
            continue
        new_url = match.group(2).replace(current, latest)
        lines[index] = line.replace(match.group(2), new_url)
        changed += 1
        following = lines[index + 1] if index + 1 < len(lines) else ""
        sha_match = sha_pattern.match(following)
        if sha_match:
            print(f"  hashing {new_url}")
            lines[index + 1] = f'{sha_match.group(1)}sha256 "{sha256_of(new_url)}"\n'
    if changed == 0:
        raise SystemExit(f"error: no url in {path.name} contains {current}")
    version_line = re.compile(rf'^(\s*)version "{re.escape(current)}"$', re.MULTILINE)
    path.write_text(version_line.sub(rf'\1version "{latest}"', "".join(lines)))


def bump_cask(name: str, latest: str) -> None:
    run("brew", "bump-cask-pr", "--write-only", "--version", latest, f"{TAP}/{name}")


def branch_exists(branch: str) -> bool:
    result = subprocess.run(
        ["git", "ls-remote", "--exit-code", "--heads", "origin", branch], cwd=ROOT, capture_output=True
    )
    return result.returncode == 0


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true", help="only list outdated packages")
    args = parser.parse_args()

    packages = outdated()
    if not packages:
        print("Everything is up to date.")
        return

    for package in packages:
        kind = "cask" if "cask" in package else "formula"
        name = package[kind]
        current, latest = package["version"]["current"], package["version"]["latest"]
        branch = f"bump/{name}-{latest}"
        print(f"{name} ({kind}): {current} -> {latest}")
        if args.dry_run:
            continue
        if branch_exists(branch):
            print(f"  {branch} already exists, skipping")
            continue

        run("git", "switch", "--quiet", "--create", branch, "origin/main")
        if kind == "cask":
            bump_cask(name, latest)
        else:
            bump_formula(name, current, latest)
        run("brew", "style", "--fix", f"{TAP}/{name}")

        title = f"{name} {latest}"
        run("git", "commit", "--quiet", "--all", "--message", title)
        run("git", "push", "--quiet", "origin", branch)
        run(
            "gh", "pr", "create", "--base", "main", "--head", branch, "--title", title,
            "--body", f"Bumps the `{name}` {kind} from {current} to {latest}, found by livecheck.",
        )
        # Pull requests opened with the workflow's own token do not start
        # other workflows, but a dispatch does: run CI on the branch so
        # the PR shows its checks.
        run("gh", "workflow", "run", "ci.yml", "--ref", branch)
        run("git", "switch", "--quiet", "--detach", "origin/main")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        sys.exit(f"error: {' '.join(error.cmd)} failed with exit status {error.returncode}")
