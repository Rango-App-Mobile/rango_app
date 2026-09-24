"""Shared helpers for the backlog/project scripts.

Everything goes through the `gh` CLI so the same code runs locally (your gh login)
and in Actions (GH_TOKEN). Project (v2) calls use PROJECT_TOKEN when it is set,
because the default GITHUB_TOKEN cannot access organization projects.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from functools import lru_cache


def _env(project: bool) -> dict[str, str]:
    env = dict(os.environ)
    if project and os.environ.get("PROJECT_TOKEN"):
        env["GH_TOKEN"] = os.environ["PROJECT_TOKEN"]
    return env


def gh(args: list[str], *, payload: dict | None = None, project: bool = False) -> str:
    cmd = ["gh", *args]
    if payload is not None:
        cmd += ["--input", "-"]
    result = subprocess.run(
        cmd,
        input=json.dumps(payload) if payload is not None else None,
        capture_output=True,
        text=True,
        env=_env(project),
    )
    if result.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd)} failed:\n{result.stderr.strip()}")
    return result.stdout


def gh_json(args: list[str], **kwargs):
    out = gh(args, **kwargs)
    return json.loads(out) if out.strip() else None


def rest_paginated(path: str) -> list:
    out = gh(["api", "--paginate", "--slurp", path])
    return [item for page in json.loads(out) for item in page]


def graphql(query: str, **variables) -> dict:
    args = ["api", "graphql", "-f", f"query={query}"]
    for key, value in variables.items():
        flag = "-F" if isinstance(value, int) else "-f"
        args += [flag, f"{key}={value}"]
    return gh_json(args, project=True)["data"]


def repo_slug() -> str:
    slug = os.environ.get("GITHUB_REPOSITORY")
    if slug:
        return slug
    return gh(["repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"]).strip()


def log(msg: str) -> None:
    print(msg, flush=True)


def warn(msg: str) -> None:
    print(f"::warning::{msg}" if os.environ.get("GITHUB_ACTIONS") else f"WARN: {msg}", file=sys.stderr, flush=True)


# ---------------------------------------------------------------- Projects v2


class Project:
    """Organization-level Projects v2 board, addressed by owner + number."""

    def __init__(self, owner: str, number: int):
        self.owner = owner
        self.number = number
        data = graphql(
            """
            query($owner: String!, $number: Int!) {
              organization(login: $owner) {
                projectV2(number: $number) {
                  id
                  fields(first: 50) {
                    nodes {
                      ... on ProjectV2FieldCommon { id name dataType }
                      ... on ProjectV2SingleSelectField { options { id name } }
                    }
                  }
                }
              }
            }
            """,
            owner=owner,
            number=number,
        )
        project = data["organization"]["projectV2"]
        self.id = project["id"]
        self.fields = {f["name"]: f for f in project["fields"]["nodes"] if f}

    @classmethod
    def from_env(cls) -> "Project | None":
        number = os.environ.get("PROJECT_NUMBER")
        if not number:
            return None
        # GITHUB_TOKEN cannot see organization projects; without PROJECT_TOKEN, skip the board
        if os.environ.get("GITHUB_ACTIONS") and not os.environ.get("PROJECT_TOKEN"):
            warn("PROJECT_TOKEN não configurado: pulando a atualização do board")
            return None
        owner = os.environ.get("PROJECT_OWNER") or repo_slug().split("/")[0]
        return cls(owner, int(number))

    def item_for(self, content_node_id: str) -> tuple[str, bool]:
        """Return (item_id, created). Adding an item that already exists is a no-op in the API."""
        existing = self._find_item(content_node_id)
        if existing:
            return existing, False
        data = graphql(
            """
            mutation($project: ID!, $content: ID!) {
              addProjectV2ItemById(input: {projectId: $project, contentId: $content}) { item { id } }
            }
            """,
            project=self.id,
            content=content_node_id,
        )
        return data["addProjectV2ItemById"]["item"]["id"], True

    def _find_item(self, content_node_id: str) -> str | None:
        data = graphql(
            """
            query($id: ID!) {
              node(id: $id) {
                ... on Issue { projectItems(first: 20) { nodes { id project { id } } } }
                ... on PullRequest { projectItems(first: 20) { nodes { id project { id } } } }
              }
            }
            """,
            id=content_node_id,
        )
        for item in (data["node"] or {}).get("projectItems", {}).get("nodes", []):
            if item["project"]["id"] == self.id:
                return item["id"]
        return None

    def current_status(self, item_id: str) -> str | None:
        data = graphql(
            """
            query($item: ID!) {
              node(id: $item) {
                ... on ProjectV2Item {
                  fieldValueByName(name: "Status") { ... on ProjectV2ItemFieldSingleSelectValue { name } }
                }
              }
            }
            """,
            item=item_id,
        )
        value = (data["node"] or {}).get("fieldValueByName")
        return value["name"] if value else None

    def set_field(self, item_id: str, field_name: str, value) -> None:
        field = self.fields.get(field_name)
        if not field:
            warn(f"Project has no field '{field_name}'; skipping")
            return
        if "options" in field:
            option = next((o for o in field["options"] if o["name"] == value), None)
            if not option:
                warn(f"Field '{field_name}' has no option '{value}'; skipping")
                return
            field_value = f'{{singleSelectOptionId: "{option["id"]}"}}'
        elif field["dataType"] == "NUMBER":
            field_value = f"{{number: {float(value)}}}"
        else:
            field_value = f"{{text: {json.dumps(str(value))}}}"
        graphql(
            f"""
            mutation($project: ID!, $item: ID!, $field: ID!) {{
              updateProjectV2ItemFieldValue(input: {{
                projectId: $project, itemId: $item, fieldId: $field, value: {field_value}
              }}) {{ projectV2Item {{ id }} }}
            }}
            """,
            project=self.id,
            item=item_id,
            field=field["id"],
        )


@lru_cache(maxsize=None)
def issue_node_id(repo: str, number: int) -> str:
    return gh_json(["api", f"repos/{repo}/issues/{number}"])["node_id"]
