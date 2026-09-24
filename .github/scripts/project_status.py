#!/usr/bin/env python3
"""Move issues on the project board.

Usage:
  python project_status.py --status "In Review" --from-text "$PR_BODY"   # issues in "Closes #12"
  python project_status.py --status "In Progress" --from-branch feat/12-swipe-screen
  python project_status.py --status "In Progress" --issue 12

Only moves forward (Backlog/Todo -> In Progress -> In Review); never touches Done.
"""

from __future__ import annotations

import argparse
import re

from gh_common import Project, issue_node_id, log, repo_slug, warn

ORDER = ["Backlog", "Todo", "In Progress", "In Review", "Done"]
CLOSING = re.compile(r"\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s+#(\d+)", re.IGNORECASE)
BRANCH = re.compile(r"^(?:feat|fix|chore|docs|refactor|test)/(\d+)-")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--status", required=True, choices=ORDER)
    parser.add_argument("--issue", type=int, action="append", default=[])
    parser.add_argument("--from-text", default="")
    parser.add_argument("--from-branch", default="")
    args = parser.parse_args()

    numbers = set(args.issue)
    numbers |= {int(n) for n in CLOSING.findall(args.from_text or "")}
    if args.from_branch and (m := BRANCH.match(args.from_branch)):
        numbers.add(int(m.group(1)))
    if not numbers:
        log("nenhuma issue referenciada; nada a fazer")
        return

    project = Project.from_env()
    if not project:
        warn("board não configurado (PROJECT_NUMBER ou PROJECT_TOKEN ausente); nada a fazer")
        return

    repo = repo_slug()
    for number in sorted(numbers):
        try:
            item_id, _ = project.item_for(issue_node_id(repo, number))
        except RuntimeError as err:
            warn(f"#{number}: {err}")
            continue
        status = project.current_status(item_id)
        if status in ORDER and ORDER.index(status) >= ORDER.index(args.status):
            log(f"#{number}: já está em '{status}', mantendo")
            continue
        project.set_field(item_id, "Status", args.status)
        log(f"#{number}: {status or '(sem status)'} -> {args.status}")


if __name__ == "__main__":
    main()
