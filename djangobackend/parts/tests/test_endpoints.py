"""Endpoint smoke tests using django-ninja's TestClient.

Auth is patched out so tests don't need real Entra tokens.
"""
from __future__ import annotations

import pytest
from django.test import Client

from parts.api import api
from parts.auth import EntraJWTBearer
from parts.models import BatchInfo, Module, Part, PartDetail, Resistor


@pytest.fixture(autouse=True)
def _bypass_auth(monkeypatch):
    """Make EntraJWTBearer.authenticate always succeed for tests."""
    monkeypatch.setattr(
        EntraJWTBearer, "authenticate", lambda self, request, token: {"sub": "test"}
    )


@pytest.fixture
def client() -> Client:
    return Client()


@pytest.fixture
def seed_data(db) -> None:
    Part.objects.create(
        batch=157, artnr="RAD FC 22/50",
        description="Elko radial", stock=6, klass="ELKO",
    )
    Module.objects.create(artnr="?", description="TMC 2130", stock=3)
    Resistor.objects.create(f_value="280", value="280", tolerance="1", comment="NA")
    BatchInfo.objects.create(batchnr=101, orderdate="2014-04-16")
    PartDetail.objects.create(
        artnr="BSS 138 SMD", description="Transistor", stock=20, klass="N-FET",
    )


HEADERS = {"HTTP_AUTHORIZATION": "Bearer dummy"}


def test_health(client: Client) -> None:
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "healthy"}


def test_list_parts(client: Client, seed_data) -> None:
    r = client.get("/api/parts", **HEADERS)
    assert r.status_code == 200
    body = r.json()
    assert len(body) == 1
    assert body[0]["artnr"] == "RAD FC 22/50"
    assert body[0]["class"] == "ELKO"
    assert body[0]["stock"] == 6


def test_find_part_case_insensitive(client: Client, seed_data) -> None:
    r = client.get("/api/parts/find?artnr=rad fc 22/50", **HEADERS)
    assert r.status_code == 200
    assert r.json()["artnr"] == "RAD FC 22/50"


def test_find_part_missing(client: Client, seed_data) -> None:
    r = client.get("/api/parts/find?artnr=nope", **HEADERS)
    assert r.status_code == 404


def test_list_modules(client: Client, seed_data) -> None:
    r = client.get("/api/modules", **HEADERS)
    assert r.status_code == 200
    assert r.json()[0]["description"] == "TMC 2130"


def test_list_resistors(client: Client, seed_data) -> None:
    r = client.get("/api/resistors", **HEADERS)
    assert r.status_code == 200
    body = r.json()
    assert body[0]["f_value"] == "280"


def test_list_batchinfo(client: Client, seed_data) -> None:
    r = client.get("/api/batchinfo", **HEADERS)
    assert r.status_code == 200
    assert r.json()[0]["batchnr"] == 101
    assert r.json()[0]["orderdate"] == "2014-04-16"


def test_get_batchinfo_by_id(client: Client, seed_data) -> None:
    r = client.get("/api/batchinfo/101", **HEADERS)
    assert r.status_code == 200
    assert r.json()["orderdate"] == "2014-04-16"


def test_get_batchinfo_missing(client: Client, seed_data) -> None:
    r = client.get("/api/batchinfo/999", **HEADERS)
    assert r.status_code == 404


def test_list_partdetails(client: Client, seed_data) -> None:
    r = client.get("/api/partdetails", **HEADERS)
    assert r.status_code == 200
    body = r.json()
    assert body[0]["class"] == "N-FET"


def test_find_partdetail(client: Client, seed_data) -> None:
    r = client.get("/api/partdetails/find?artnr=bss 138 smd", **HEADERS)
    assert r.status_code == 200
    assert r.json()["artnr"] == "BSS 138 SMD"


def test_missing_token_returns_401(client: Client, seed_data, monkeypatch) -> None:
    monkeypatch.setattr(
        EntraJWTBearer, "authenticate", lambda self, request, token: None
    )
    r = client.get("/api/parts")
    assert r.status_code == 401
