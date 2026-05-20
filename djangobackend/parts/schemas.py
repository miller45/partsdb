"""Ninja schemas matching the JSON wire format produced by the .NET API.

`Part` and `PartDetail` have a `class` field whose name collides with the
Python `class` keyword. django-ninja serialization uses field names by
default, so for those two endpoints we return plain dicts built by
:func:`part_to_dict` / :func:`part_detail_to_dict` with explicit ``class``
keys. The remaining schemas use straight field-name serialization.
"""
from __future__ import annotations

from typing import Any

from ninja import Schema

from .models import Part, PartDetail


class ModuleSchema(Schema):
    artnr: str
    description: str
    stock: int


class ResistorSchema(Schema):
    f_value: str
    value: str
    tolerance: str
    comment: str


class BatchInfoSchema(Schema):
    batchnr: int
    orderdate: str


class ErrorSchema(Schema):
    detail: str


def part_to_dict(p: Part) -> dict[str, Any]:
    return {
        "batch": p.batch,
        "artnr": p.artnr,
        "description": p.description,
        "stock": p.stock,
        "class": p.klass,
        "value1": p.value1,
        "value2": p.value2,
        "mark": p.mark,
    }


def part_detail_to_dict(p: PartDetail) -> dict[str, Any]:
    return {
        "artnr": p.artnr,
        "description": p.description,
        "stock": p.stock,
        "class": p.klass,
    }
