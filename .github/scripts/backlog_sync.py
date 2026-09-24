#!/usr/bin/env python3
"""Sync .github/backlog/backlog.yml -> labels, milestones, issues, sub-issues and the project board.

Idempotent: issues are matched by the `<!-- backlog-id: X -->` marker in their body.

Usage:
  python .github/scripts/backlog_sync.py --offline   # only validate the YAML and print the plan
  python .github/scripts/backlog_sync.py --dry-run   # read GitHub, print what would change
  python .github/scripts/backlog_sync.py             # apply

Env: GH_TOKEN (repo), PROJECT_TOKEN + PROJECT_NUMBER (optional, board sync).
"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

import yaml

from gh_common import Project, gh, gh_json, log, repo_slug, rest_paginated, warn

BACKLOG = Path(__file__).resolve().parents[1] / "backlog" / "backlog.yml"
MARKER = re.compile(r"<!-- backlog-id: (\S+) -->")
HASH_MARKER = re.compile(r"<!-- backlog-hash: (\w+) -->")
FRENTES = {"dev": "Dev", "marketing": "Marketing", "produto": "Produto"}
PRIORITIES = {"alta", "media", "baixa"}


@dataclass
class Item:
    id: str
    title: str
    kind: str  # "epic" | "story"
    frente: str
    area: str
    description: str = ""
    acceptance: list[str] = field(default_factory=list)
    sprint: int | None = None
    priority: str | None = None
    estimate: float | None = None
    done: bool = False
    epic: "Item | None" = None

    @property
    def labels(self) -> list[str]:
        labels = [f"type:{self.kind}", f"frente:{self.frente}", f"area:{self.area}"]
        if self.priority:
            labels.append(f"priority:{self.priority}")
        return labels

    @property
    def milestone_title(self) -> str | None:
        return f"Sprint {self.sprint}" if self.sprint else None

    def body(self) -> str:
        parts = [self.description.strip() or "_Sem descrição._"]
        if self.acceptance:
            parts.append("## Critérios de aceitação\n" + "\n".join(f"- [ ] {c}" for c in self.acceptance))
        meta = [f"**Frente:** {FRENTES[self.frente]}", f"**Área:** {self.area}"]
        if self.epic:
            meta.insert(0, f"**Épico:** {self.epic.id} — {self.epic.title}")
        meta.append(f"**Sprint:** {self.sprint}" if self.sprint else "**Sprint:** backlog futuro")
        if self.estimate is not None:
            meta.append(f"**Estimativa:** {self.estimate:g} pts")
        parts.append(" · ".join(meta))
        parts.append(
            "<sub>Gerada a partir de `.github/backlog/backlog.yml`. Edite lá para mudar título, "
            "descrição, critérios, sprint ou labels; converse nos comentários.</sub>"
        )
        content = "\n\n".join(parts)
        digest = hashlib.sha1(content.encode()).hexdigest()[:10]
        return f"{content}\n\n<!-- backlog-id: {self.id} -->\n<!-- backlog-hash: {digest} -->"


def load() -> tuple[dict, list[Item]]:
    data = yaml.safe_load(BACKLOG.read_text(encoding="utf-8"))
    sprints = {m["sprint"] for m in data["milestones"]}
    label_names = {lbl["name"] for lbl in data["labels"]}
    items: list[Item] = []
    errors: list[str] = []

    def build(raw: dict, kind: str, epic: Item | None = None) -> Item:
        item = Item(
            id=raw["id"],
            title=raw["title"],
            kind=kind,
            frente=raw.get("frente", epic.frente if epic else "dev"),
            area=raw.get("area", epic.area if epic else "infra"),
            description=raw.get("description") or "",
            acceptance=raw.get("acceptance") or [],
            sprint=raw.get("sprint"),
            priority=raw.get("priority"),
            estimate=raw.get("estimate"),
            done=bool(raw.get("done", False)),
            epic=epic,
        )
        if item.frente not in FRENTES:
            errors.append(f"{item.id}: frente '{item.frente}' inválida")
        if item.sprint is not None and item.sprint not in sprints:
            errors.append(f"{item.id}: sprint {item.sprint} não existe em milestones")
        if item.priority and item.priority not in PRIORITIES:
            errors.append(f"{item.id}: priority '{item.priority}' inválida")
        for label in item.labels:
            if label not in label_names:
                errors.append(f"{item.id}: label '{label}' não declarada em labels")
        return item

    for raw_epic in data["epics"]:
        epic = build(raw_epic, "epic")
        items.append(epic)
        for raw_story in raw_epic.get("stories", []):
            items.append(build(raw_story, "story", epic))

    ids = [i.id for i in items]
    errors += [f"id duplicado: {i}" for i in sorted({i for i in ids if ids.count(i) > 1})]
    if errors:
        sys.exit("backlog.yml inválido:\n  " + "\n  ".join(errors))
    return data, items


class Sync:
    def __init__(self, data: dict, items: list[Item], dry_run: bool):
        self.data = data
        self.items = items
        self.dry = dry_run
        self.repo = repo_slug()
        self.changes = 0

    def act(self, description: str, fn=None):
        self.changes += 1
        log(("[dry-run] " if self.dry else "") + description)
        if not self.dry and fn:
            return fn()
        return None

    def labels(self) -> None:
        existing = {lbl["name"]: lbl for lbl in rest_paginated(f"repos/{self.repo}/labels?per_page=100")}
        for lbl in self.data["labels"]:
            current = existing.get(lbl["name"])
            if current and current["color"] == lbl["color"] and (current["description"] or "") == lbl["description"]:
                continue
            self.act(
                f"label {'update' if current else 'create'}: {lbl['name']}",
                lambda lbl=lbl: gh(
                    ["label", "create", lbl["name"], "--color", lbl["color"],
                     "--description", lbl["description"], "--force", "--repo", self.repo]
                ),
            )

    def milestones(self) -> dict[str, int]:
        existing = {m["title"]: m for m in rest_paginated(f"repos/{self.repo}/milestones?state=all&per_page=100")}
        numbers: dict[str, int] = {}
        for m in self.data["milestones"]:
            title = f"Sprint {m['sprint']}"
            payload = {"title": title, "description": m["description"], "due_on": f"{m['due_on']}T12:00:00Z"}
            current = existing.get(title)
            if current:
                numbers[title] = current["number"]
                same_due = (current.get("due_on") or "")[:10] == m["due_on"]
                if same_due and (current.get("description") or "") == m["description"]:
                    continue
                self.act(f"milestone update: {title}", lambda c=current, p=payload: gh(
                    ["api", "-X", "PATCH", f"repos/{self.repo}/milestones/{c['number']}"], payload=p))
            else:
                created = self.act(f"milestone create: {title}", lambda p=payload: gh_json(
                    ["api", "-X", "POST", f"repos/{self.repo}/milestones"], payload=p))
                numbers[title] = created["number"] if created else -1
        return numbers

    def issues(self, milestones: dict[str, int]) -> dict[str, dict]:
        existing: dict[str, dict] = {}
        for issue in rest_paginated(f"repos/{self.repo}/issues?state=all&per_page=100"):
            if "pull_request" in issue:
                continue
            match = MARKER.search(issue.get("body") or "")
            if match:
                existing[match.group(1)] = issue

        by_id: dict[str, dict] = {}
        for item in self.items:
            body = item.body()
            milestone = milestones.get(item.milestone_title) if item.milestone_title else None
            current = existing.get(item.id)
            if not current:
                payload = {"title": item.title, "body": body, "labels": item.labels}
                if milestone:
                    payload["milestone"] = milestone
                created = self.act(f"issue create: [{item.id}] {item.title}", lambda p=payload: gh_json(
                    ["api", "-X", "POST", f"repos/{self.repo}/issues"], payload=p))
                current = created or {"number": None, "id": None, "node_id": None, "state": "open"}
            else:
                patch: dict = {}
                if current["title"] != item.title:
                    patch["title"] = item.title
                old_hash = HASH_MARKER.search(current.get("body") or "")
                new_hash = HASH_MARKER.search(body)
                if not old_hash or old_hash.group(1) != new_hash.group(1):
                    patch["body"] = body
                current_labels = {lbl["name"] for lbl in current["labels"]}
                managed = {lbl["name"] for lbl in self.data["labels"]} - {"blocked"}
                wanted = (current_labels - managed) | set(item.labels)
                if wanted != current_labels:
                    patch["labels"] = sorted(wanted)
                current_ms = (current.get("milestone") or {}).get("number")
                if current_ms != milestone:
                    patch["milestone"] = milestone
                if patch:
                    self.act(f"issue update #{current['number']} [{item.id}]: {', '.join(patch)}",
                             lambda c=current, p=patch: gh(
                                 ["api", "-X", "PATCH", f"repos/{self.repo}/issues/{c['number']}"], payload=p))
            if item.done and current.get("state") == "open" and current.get("number"):
                self.act(f"issue close #{current['number']} [{item.id}] (done: true)", lambda c=current: gh(
                    ["api", "-X", "PATCH", f"repos/{self.repo}/issues/{c['number']}"],
                    payload={"state": "closed", "state_reason": "completed"}))
            by_id[item.id] = current

        declared = {i.id for i in self.items}
        for orphan in sorted(set(existing) - declared):
            warn(f"issue #{existing[orphan]['number']} [{orphan}] não está mais no backlog.yml (não foi fechada)")
        return by_id

    def sub_issues(self, issues: dict[str, dict]) -> None:
        for epic in (i for i in self.items if i.kind == "epic"):
            epic_issue = issues.get(epic.id)
            if not epic_issue or not epic_issue.get("number"):
                continue
            try:
                children = {c["number"] for c in rest_paginated(
                    f"repos/{self.repo}/issues/{epic_issue['number']}/sub_issues?per_page=100")}
            except RuntimeError as err:
                warn(f"sub-issues indisponíveis: {err}")
                return
            for story in (i for i in self.items if i.epic is epic):
                story_issue = issues.get(story.id)
                if not story_issue or not story_issue.get("id") or story_issue["number"] in children:
                    continue
                try:
                    self.act(f"sub-issue: #{story_issue['number']} -> épico #{epic_issue['number']}", lambda e=epic_issue, s=story_issue: gh(
                        ["api", "-X", "POST", f"repos/{self.repo}/issues/{e['number']}/sub_issues"],
                        payload={"sub_issue_id": s["id"]}))
                except RuntimeError as err:
                    warn(f"não foi possível ligar {story.id} ao {epic.id}: {err}")

    def project(self, issues: dict[str, dict]) -> None:
        project = Project.from_env()
        if not project:
            log("board não configurado (PROJECT_NUMBER ou PROJECT_TOKEN ausente): pulando sync do board")
            return
        for item in self.items:
            issue = issues.get(item.id)
            if not issue or not issue.get("node_id"):
                continue
            if self.dry:
                log(f"[dry-run] board: [{item.id}] Frente={FRENTES[item.frente]} Sprint={item.milestone_title or 'Futuro'}")
                continue
            item_id, created = project.item_for(issue["node_id"])
            project.set_field(item_id, "Frente", FRENTES[item.frente])
            if item.kind == "story":  # épicos atravessam várias sprints
                project.set_field(item_id, "Sprint", item.milestone_title or "Futuro")
            project.set_field(item_id, "Area", item.area)
            if item.estimate is not None:
                project.set_field(item_id, "Estimate", item.estimate)
            # set Status when the item is new or has none yet; never override a status the team moved by hand
            if created or not project.current_status(item_id):
                planned = item.sprint or any(s.sprint for s in self.items if s.epic is item)
                status = "Done" if item.done else ("Todo" if planned else "Backlog")
                project.set_field(item_id, "Status", status)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true", help="lê o GitHub e mostra o que mudaria")
    parser.add_argument("--offline", action="store_true", help="só valida o YAML")
    args = parser.parse_args()

    data, items = load()
    if args.offline:
        for item in items:
            prefix = "" if item.kind == "epic" else "  "
            sprint = "-" if item.kind == "epic" else (item.milestone_title or "futuro")
            log(f"{prefix}[{item.id}] {item.title} | {sprint} | {', '.join(item.labels)}"
                + (" | done" if item.done else ""))
        log(f"OK: {len(items)} itens, {len(data['milestones'])} sprints, {len(data['labels'])} labels")
        return

    sync = Sync(data, items, dry_run=args.dry_run)
    sync.labels()
    milestones = sync.milestones()
    issues = sync.issues(milestones)
    sync.sub_issues(issues)
    sync.project(issues)
    log(f"{'[dry-run] ' if args.dry_run else ''}{sync.changes} alteração(ões)")


if __name__ == "__main__":
    main()
