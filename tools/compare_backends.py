#!/usr/bin/env python3
"""Compare JSON responses from the .NET and Django backends.

Run both backends locally (.NET on :5287, Django on :8000) and pass a valid
Entra ID bearer token::

    python tools/compare_backends.py --token "$JWT"

Exits 0 if every endpoint returns equal JSON (sorted), non-zero otherwise.
"""
from __future__ import annotations

import argparse
import json
import sys
from typing import Any
from urllib import error, request

ENDPOINTS = [
    "/api/parts",
    "/api/parts/find?artnr=RAD FC 22/50",
    "/api/modules",
    "/api/resistors",
    "/api/batchinfo",
    "/api/batchinfo/101",
    "/api/partdetails",
    "/api/partdetails/find?artnr=BSS 138 SMD",
]


def fetch(base: str, path: str, token: str) -> tuple[int, Any]:
    url = base.rstrip("/") + path
    # urllib doesn't auto-encode the query string; use a simple replace.
    url = url.replace(" ", "%20")
    req = request.Request(url, headers={"Authorization": f"Bearer {token}"})
    try:
        with request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8")
            return resp.status, json.loads(body) if body else None
    except error.HTTPError as exc:
        return exc.code, exc.read().decode("utf-8", "replace")


def canonical(obj: Any) -> str:
    """Stable string representation: sort keys + sort lists of dicts."""
    if isinstance(obj, list):
        try:
            obj = sorted(obj, key=lambda x: json.dumps(x, sort_keys=True))
        except TypeError:
            pass
    return json.dumps(obj, sort_keys=True, default=str)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--dotnet", default="http://localhost:5287")
    p.add_argument("--django", default="http://localhost:8000")
    p.add_argument("--token", required=True, help="Bearer token")
    args = p.parse_args()

    failures = 0
    for path in ENDPOINTS:
        a_status, a_body = fetch(args.dotnet, path, args.token)
        b_status, b_body = fetch(args.django, path, args.token)
        same = a_status == b_status and canonical(a_body) == canonical(b_body)
        marker = "OK " if same else "DIFF"
        print(f"  [{marker}] {path}  (.NET={a_status}, Django={b_status})")
        if not same:
            failures += 1
            print(f"      .NET:   {canonical(a_body)[:200]}")
            print(f"      Django: {canonical(b_body)[:200]}")

    if failures:
        print(f"\n{failures}/{len(ENDPOINTS)} endpoint(s) differ.")
        return 1
    print(f"\nAll {len(ENDPOINTS)} endpoints match.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
