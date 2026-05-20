"""Unit tests for ``parts.services.coerce_int``."""
from __future__ import annotations

import pytest

from parts.services import coerce_int


@pytest.mark.parametrize(
    "value,expected",
    [
        (None, None),
        (0, 0),
        (6, 6),
        (-3, -3),
        ("6", 6),
        ("  42 ", 42),
        ("", None),
        ("abc", None),
        ("3.7", 3),
        (3.7, 3),
    ],
)
def test_coerce_int(value, expected) -> None:
    assert coerce_int(value) == expected
