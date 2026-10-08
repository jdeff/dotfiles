#!/usr/bin/env python3
"""List your Devin Cloud sessions for devin-cloud-pick.sh.

Speaks ACP to `devin acp --cloud` and calls `session/list`, so it rides the CLI's
own login (`devin auth login`) instead of needing a Devin API token.

Prints one tab-separated line per unarchived session, newest first:
    <session-id> <TAB> <display line>
and writes the raw session objects to the JSON file given as argv[1], keyed by
session id, for fzf's preview.
"""
import json
import os
import select
import subprocess
import sys
import time
from datetime import datetime, timezone

TIMEOUT = 20
M = "cognition.ai/"


def rpc(proc, req_id, method, params):
    proc.stdin.write(json.dumps({"jsonrpc": "2.0", "id": req_id, "method": method, "params": params}) + "\n")
    proc.stdin.flush()
    deadline = time.time() + TIMEOUT
    while time.time() < deadline:
        ready, _, _ = select.select([proc.stdout], [], [], 0.5)
        if not ready:
            continue
        line = proc.stdout.readline()
        if not line:
            break
        msg = json.loads(line)
        if msg.get("id") == req_id:
            if "error" in msg:
                raise RuntimeError(msg["error"].get("message", msg["error"]))
            return msg["result"]
    raise RuntimeError(f"no reply to {method} within {TIMEOUT}s")


def list_sessions():
    proc = subprocess.Popen(
        ["devin", "acp", "--cloud"],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
        text=True, bufsize=1,
    )
    try:
        rpc(proc, 1, "initialize", {"protocolVersion": 1, "clientCapabilities": {}})
        sessions, cursor, req_id = [], None, 2
        while True:
            result = rpc(proc, req_id, "session/list", {"cursor": cursor} if cursor else {})
            sessions += result.get("sessions", [])
            cursor = result.get("nextCursor")
            if not cursor:
                return sessions
            req_id += 1
    finally:
        proc.kill()


def age(iso):
    try:
        secs = (datetime.now(timezone.utc) - datetime.fromisoformat(iso)).total_seconds()
    except (TypeError, ValueError):
        return "?"
    for unit, size in (("d", 86400), ("h", 3600), ("m", 60)):
        if secs >= size:
            return f"{int(secs // size)}{unit}"
    return "now"


def main():
    cache_path = sys.argv[1]
    try:
        sessions = list_sessions()
    except Exception as e:  # surfaced in the picker pane
        print(f"devin-cloud-sessions: {e} (try `devin auth status`)", file=sys.stderr)
        sys.exit(1)

    sessions = [s for s in sessions if not s.get("_meta", {}).get(M + "isArchived")]
    sessions.sort(key=lambda s: s.get("_meta", {}).get(M + "sortUpdatedAt") or "", reverse=True)

    with open(cache_path, "w") as f:
        json.dump({s["sessionId"]: s for s in sessions}, f)

    for s in sessions:
        meta = s.get("_meta", {})
        unread = "●" if meta.get(M + "isUnread") else " "
        status = meta.get(M + "sessionStatus") or "?"
        repos = ",".join(r["name"].split("/")[-1] for r in meta.get(M + "sessionRepos") or [])
        title = (s.get("title") or "(untitled)").replace("\t", " ")
        when = age(meta.get(M + "sortUpdatedAt") or s.get("updatedAt"))
        print(f"{s['sessionId']}\t{unread} {status:<10} {when:>4}  {title}  \033[2m{repos}\033[0m")


if __name__ == "__main__":
    main()
