"""Helpers shared by API code and the import command."""
from __future__ import annotations

from typing import Any


def coerce_int(value: Any) -> int | None:
    """Mirror of webbackend ``FlexibleIntConverter``.

    Accepts ``int``, numeric ``str``, or ``None``/empty/non-numeric and
    returns ``int`` or ``None``.
    """
    if value is None:
        return None
    if isinstance(value, bool):
        # bool is a subclass of int; reject to match .NET behaviour
        return int(value)
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        return int(value)
    if isinstance(value, str):
        s = value.strip()
        if not s:
            return None
        try:
            return int(s)
        except ValueError:
            try:
                return int(float(s))
            except ValueError:
                return None
    return None
