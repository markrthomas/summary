#!/usr/bin/env python3
"""Refresh README.md with current git state for all sub-repos.

Auto-updated regions:
  - Opening paragraph: total repo count and "inspected on" date.
  - "At a glance" bullets: the "State: ..." phrase per repo.
  - Per-repo sections: "Current state:" and "Last commit:" bullets.

Historical regions (left untouched):
  - "## YYYY-MM-DD maintenance update" heading and its prose.
  - The "Verification stamp" line.
  - Per-repo Purpose / Highlights / Plan prose.
"""

import datetime
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
README = ROOT / "README.md"


def sub_repos():
    return sorted(p.name for p in ROOT.iterdir() if p.is_dir() and (p / ".git").exists())


def git(repo, *args):
    return subprocess.check_output(
        ["git", "-C", str(ROOT / repo), *args],
        text=True,
        stderr=subprocess.DEVNULL,
    ).strip()


def repo_state(repo):
    try:
        branch = git(repo, "rev-parse", "--abbrev-ref", "HEAD")
    except subprocess.CalledProcessError:
        branch = "(detached)"
    try:
        sha = git(repo, "log", "-1", "--format=%h")
        subject = git(repo, "log", "-1", "--format=%s")
        has_commits = True
    except subprocess.CalledProcessError:
        sha = ""
        subject = ""
        has_commits = False
        try:
            branch_full = git(repo, "symbolic-ref", "--short", "HEAD")
            branch = branch_full
        except subprocess.CalledProcessError:
            pass
    porcelain = git(repo, "status", "--porcelain")
    has_upstream = True
    ahead = behind = 0
    if has_commits:
        try:
            ab = git(repo, "rev-list", "--left-right", "--count", "HEAD...@{u}")
            ahead, behind = (int(x) for x in ab.split())
        except subprocess.CalledProcessError:
            has_upstream = False
    else:
        has_upstream = False
    modified = [ln for ln in porcelain.splitlines() if not ln.startswith("??")]
    untracked = [ln[3:] for ln in porcelain.splitlines() if ln.startswith("??")]
    return dict(
        branch=branch, sha=sha, subject=subject,
        ahead=ahead, behind=behind, has_upstream=has_upstream,
        modified=modified, untracked=untracked,
        has_commits=has_commits,
    )


def _sync_phrase(s):
    parts = []
    if s["ahead"]:
        parts.append(f"ahead {s['ahead']}")
    if s["behind"]:
        parts.append(f"behind {s['behind']}")
    return ", ".join(parts)


def _fmt_files(files, cap=3):
    if len(files) <= cap:
        return ", ".join(f"`{u}`" for u in files)
    head = ", ".join(f"`{u}`" for u in files[:cap])
    return f"{head}, and {len(files) - cap} more"


def short_state(s):
    """Compact 'At a glance' state phrase."""
    if s["modified"]:
        cleanliness = "dirty"
    elif s["untracked"]:
        cleanliness = f"clean except untracked {_fmt_files(s['untracked'], cap=2)}"
    else:
        cleanliness = "clean"
    sync = _sync_phrase(s)
    tail = f", {sync} of `origin/{s['branch']}`" if sync else ""
    return f"`{s['branch']}`, {cleanliness}{tail}"


def long_state(s):
    """Per-repo 'Current state:' phrase."""
    if not s["modified"] and not s["untracked"] and s["ahead"] == 0 and s["behind"] == 0:
        return f"clean working tree on `{s['branch']}`."
    head = f"`{s['branch']}`"
    sync = _sync_phrase(s)
    if s["has_upstream"]:
        head += f" {sync} of `origin/{s['branch']}`" if sync else f" aligned with `origin/{s['branch']}`"
    extras = []
    if s["modified"]:
        extras.append(f"**dirty** ({len(s['modified'])} uncommitted change(s))")
    if s["untracked"]:
        extras.append(f"**untracked** {_fmt_files(s['untracked'], cap=4)} locally")
    if not extras:
        return head + "."
    return head + "; " + "; ".join(extras) + "."


def update():
    text = README.read_text()
    today = datetime.date.today().isoformat()
    repos = sub_repos()
    states = {r: repo_state(r) for r in repos}

    documented = set(re.findall(r"^### `([^`]+)`\s*$", text, flags=re.MULTILINE))
    on_disk = set(repos)
    missing = sorted(on_disk - documented)
    stale = sorted(documented - on_disk)
    if missing:
        print(f"warn: {len(missing)} sub-repo(s) on disk but not in README: {', '.join(missing)}", file=sys.stderr)
        print("      add an 'At a glance' bullet and a `### \\`<repo>\\`` section, then re-run make.", file=sys.stderr)
    if stale:
        print(f"warn: {len(stale)} README section(s) refer to repos no longer on disk: {', '.join(stale)}", file=sys.stderr)

    text = re.sub(
        r"This directory contains \d+ Git repositories\.(.*?)inspected on \*\*\d{4}-\d{2}-\d{2}\*\*\.",
        lambda m: f"This directory contains {len(repos)} Git repositories.{m.group(1)}inspected on **{today}**.",
        text, count=1, flags=re.DOTALL,
    )

    for repo, s in states.items():
        pattern = rf"(^- `{re.escape(repo)}`: .*? State: )(.+?)(\. Plan: )"
        text, n = re.subn(
            pattern,
            lambda m: m.group(1) + short_state(s) + m.group(3),
            text, count=1, flags=re.MULTILINE | re.DOTALL,
        )
        if n == 0:
            print(f"warn: no 'At a glance' bullet found for `{repo}`", file=sys.stderr)

    for repo, s in states.items():
        header_re = rf"^### `{re.escape(repo)}`\s*$"
        m = re.search(header_re, text, flags=re.MULTILINE)
        if not m:
            print(f"warn: no section heading for `{repo}`", file=sys.stderr)
            continue
        start = m.end()
        next_m = re.search(r"^#+ ", text[start:], flags=re.MULTILINE)
        end = start + (next_m.start() if next_m else len(text) - start)
        section = text[start:end]
        subject = s["subject"].replace('"', "'")
        new_section, n_cs = re.subn(
            r"^- Current state: .*$",
            "- Current state: " + long_state(s),
            section, count=1, flags=re.MULTILINE,
        )
        trailing_dot = "" if subject.endswith(".") else "."
        new_section, n_lc = re.subn(
            r"^- Last commit: `[0-9a-f]+` — \".*?\"\.?\s*$",
            f'- Last commit: `{s["sha"]}` — "{subject}"{trailing_dot}',
            new_section, count=1, flags=re.MULTILINE,
        )
        if n_cs == 0:
            print(f"warn: no 'Current state' line for `{repo}`", file=sys.stderr)
        if n_lc == 0:
            print(f"warn: no 'Last commit' line for `{repo}`", file=sys.stderr)
        text = text[:start] + new_section + text[end:]

    README.write_text(text)
    print(f"README.md refreshed for {len(repos)} repos as of {today}.")


if __name__ == "__main__":
    update()
