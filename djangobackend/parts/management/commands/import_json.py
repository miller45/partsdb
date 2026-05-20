"""Import the legacy webbackend JSON files into the Django database.

Usage::

    python manage.py import_json --data-dir ../webbackend/Data [--flush]

The command is idempotent: when ``--flush`` is given, existing rows are
deleted first; otherwise rows are upserted by their natural key
(``artnr`` for Part/Module/PartDetail, ``batchnr`` for BatchInfo,
composite for Resistor).
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from parts.models import BatchInfo, Module, Part, PartDetail, Resistor
from parts.services import coerce_int


class Command(BaseCommand):
    help = "Import legacy webbackend/Data/*.json into the Django database."

    def add_arguments(self, parser) -> None:
        parser.add_argument(
            "--data-dir",
            default="../webbackend/Data",
            help="Path to the directory containing the JSON files.",
        )
        parser.add_argument(
            "--flush",
            action="store_true",
            help="Delete all existing rows before importing.",
        )

    def handle(self, *args: Any, **opts: Any) -> None:
        data_dir = Path(opts["data_dir"]).resolve()
        if not data_dir.is_dir():
            raise CommandError(f"--data-dir does not exist: {data_dir}")

        self.stdout.write(self.style.NOTICE(f"Importing JSON from {data_dir}"))

        with transaction.atomic():
            if opts["flush"]:
                self.stdout.write("  Flushing existing rows…")
                Part.objects.all().delete()
                Module.objects.all().delete()
                Resistor.objects.all().delete()
                BatchInfo.objects.all().delete()
                PartDetail.objects.all().delete()

            self._import_parts(data_dir / "parts.json")
            self._import_modules(data_dir / "modules.json")
            self._import_resistors(data_dir / "myresistors.json")
            self._import_batchinfo(data_dir / "batchinfo.json")
            self._import_partdetails(data_dir / "partsdetails.json")

        self.stdout.write(self.style.SUCCESS("Import complete."))

    # ── Helpers ──────────────────────────────────────────────────────────────
    @staticmethod
    def _load(path: Path) -> Any:
        with path.open(encoding="utf-8") as f:
            return json.load(f)

    def _import_parts(self, path: Path) -> None:
        rows = self._load(path)["parts"]
        for row in rows:
            Part.objects.update_or_create(
                batch=row["batch"],
                artnr=row["artnr"],
                defaults={
                    "description": row.get("description", "") or "",
                    "stock": coerce_int(row.get("stock")),
                    "klass": row.get("class"),
                    "value1": row.get("value1"),
                    "value2": row.get("value2"),
                    "mark": row.get("mark"),
                },
            )
        self.stdout.write(f"  Parts: {len(rows)}")

    def _import_modules(self, path: Path) -> None:
        rows = self._load(path)["modules"]
        # Modules in the JSON often share the placeholder artnr "?";
        # use position-based upsert by (artnr, description) pair.
        for row in rows:
            Module.objects.update_or_create(
                artnr=row.get("artnr", ""),
                description=row.get("description", "") or "",
                defaults={"stock": coerce_int(row.get("stock")) or 0},
            )
        self.stdout.write(f"  Modules: {len(rows)}")

    def _import_resistors(self, path: Path) -> None:
        rows = self._load(path)
        # Resistor has no natural key; flush+insert is simplest. If
        # --flush was not requested, append rows that don't already
        # match the full tuple.
        for row in rows:
            Resistor.objects.update_or_create(
                f_value=row["f_value"],
                value=row["value"],
                tolerance=row["tolerance"],
                comment=row.get("comment", "") or "",
            )
        self.stdout.write(f"  Resistors: {len(rows)}")

    def _import_batchinfo(self, path: Path) -> None:
        rows = self._load(path)["batchinfo"]
        for row in rows:
            BatchInfo.objects.update_or_create(
                batchnr=row["batchnr"],
                defaults={"orderdate": row.get("orderdate", "") or ""},
            )
        self.stdout.write(f"  BatchInfo: {len(rows)}")

    def _import_partdetails(self, path: Path) -> None:
        rows = self._load(path)["partsdetails"]
        for row in rows:
            PartDetail.objects.update_or_create(
                artnr=row["artnr"],
                defaults={
                    "description": row.get("description", "") or "",
                    "stock": coerce_int(row.get("stock")),
                    "klass": row.get("class"),
                },
            )
        self.stdout.write(f"  PartDetails: {len(rows)}")
