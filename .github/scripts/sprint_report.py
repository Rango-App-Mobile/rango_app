#!/usr/bin/env python3
"""Summarize the current sprint (milestone) by frente, for review/retro.

Writes markdown to stdout and to $GITHUB_STEP_SUMMARY, and (with --comment) posts it on the
sprint tracking issue "Sprint N — acompanhamento" (label type:sprint), creating it if needed.

Usage: python sprint_report.py [--sprint N] [--comment]
"""

from __future__ import annotations

import argparse
import os
import re
from collections import defaultdict
from datetime import date

from gh_common import gh_json, log, repo_slug, rest_paginated

FRENTES = ["dev", "marketing", "produto"]


def pick_milestone(repo: str, sprint: int | None) -> dict:
    milestones = [m for m in rest_paginated(f"repos/{repo}/milestones?state=all&per_page=100")
                  if m["title"].startswith("Sprint ")]
    if sprint:
        return next(m for m in milestones if m["title"] == f"Sprint {sprint}")
    today = date.today().isoformat()
    upcoming = sorted((m for m in milestones if (m.get("due_on") or "")[:10] >= today), key=lambda m: m["due_on"])
    return upcoming[0] if upcoming else sorted(milestones, key=lambda m: m["due_on"] or "")[-1]


def points(issue: dict) -> float:
    match = re.search(r"\*\*Estimativa:\*\* ([\d.]+) pts", issue.get("body") or "")
    return float(match.group(1)) if match else 0.0


def render(repo: str, milestone: dict) -> str:
    issues = [i for i in rest_paginated(
        f"repos/{repo}/issues?milestone={milestone['number']}&state=all&per_page=100")
        if "pull_request" not in i and not any(lbl["name"] == "type:sprint" for lbl in i["labels"])]

    groups: dict[str, list[dict]] = defaultdict(list)
    for issue in issues:
        labels = {lbl["name"] for lbl in issue["labels"]}
        frente = next((f for f in FRENTES if f"frente:{f}" in labels), "sem frente")
        groups[frente].append(issue)

    closed = [i for i in issues if i["state"] == "closed"]
    total_pts = sum(points(i) for i in issues)
    done_pts = sum(points(i) for i in closed)
    pct = round(100 * len(closed) / len(issues)) if issues else 0

    lines = [
        f"# {milestone['title']} — acompanhamento ({date.today().strftime('%d/%m/%Y')})",
        "",
        f"Prazo: **{(milestone.get('due_on') or '')[:10]}** · {milestone.get('description') or ''}",
        "",
        f"**Progresso:** {len(closed)}/{len(issues)} issues ({pct}%) · {done_pts:g}/{total_pts:g} pts",
        "",
        "| Frente | Concluídas | Abertas | Pontos feitos |",
        "|---|---|---|---|",
    ]
    for frente in [*FRENTES, "sem frente"]:
        group = groups.get(frente)
        if not group:
            continue
        done = [i for i in group if i["state"] == "closed"]
        lines.append(f"| {frente} | {len(done)} | {len(group) - len(done)} | "
                     f"{sum(points(i) for i in done):g}/{sum(points(i) for i in group):g} |")

    open_issues = [i for i in issues if i["state"] == "open"]
    if open_issues:
        lines += ["", "## Em aberto", ""]
        for issue in sorted(open_issues, key=lambda i: i["number"]):
            who = ", ".join(f"@{a['login']}" for a in issue["assignees"]) or "_sem responsável_"
            blocked = " 🚧 **bloqueada**" if any(lbl["name"] == "blocked" for lbl in issue["labels"]) else ""
            lines.append(f"- #{issue['number']} {issue['title']} — {who}{blocked}")

    lines += [
        "",
        "## Para a review/retro",
        "",
        "- O que foi entregue e demonstrado?",
        "- O que não fechou e por quê? Volta para qual sprint?",
        "- Manter / melhorar / parar (registrar respostas como comentário nesta issue)",
    ]
    return "\n".join(lines)


def tracking_issue(repo: str, milestone: dict) -> int:
    title = f"{milestone['title']} — acompanhamento"
    for issue in rest_paginated(f"repos/{repo}/issues?labels=type:sprint&state=all&per_page=100"):
        if issue["title"] == title:
            return issue["number"]
    created = gh_json(["api", "-X", "POST", f"repos/{repo}/issues"], payload={
        "title": title,
        "labels": ["type:sprint"],
        "milestone": milestone["number"],
        "body": "Issue de acompanhamento da sprint: relatórios automáticos, notas da review e da retro.",
    })
    return created["number"]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sprint", type=int)
    parser.add_argument("--comment", action="store_true")
    args = parser.parse_args()

    repo = repo_slug()
    milestone = pick_milestone(repo, args.sprint)
    report = render(repo, milestone)
    log(report)
    if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(summary, "a", encoding="utf-8") as fh:
            fh.write(report + "\n")
    if args.comment:
        number = tracking_issue(repo, milestone)
        gh_json(["api", "-X", "POST", f"repos/{repo}/issues/{number}/comments"], payload={"body": report})
        log(f"comentado em #{number}")


if __name__ == "__main__":
    main()
