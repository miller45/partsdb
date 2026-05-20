"""django-ninja API mirroring the .NET controllers under /api."""
from __future__ import annotations

from django.shortcuts import get_object_or_404
from ninja import NinjaAPI
from ninja.errors import HttpError

from .auth import EntraJWTBearer
from .models import BatchInfo, Module, Part, PartDetail, Resistor
from .schemas import (
    BatchInfoSchema,
    ModuleSchema,
    ResistorSchema,
    part_detail_to_dict,
    part_to_dict,
)

api = NinjaAPI(
    title="PartsDB API",
    version="1.0.0",
    auth=EntraJWTBearer(),
    urls_namespace="api",
)


# ── Parts ────────────────────────────────────────────────────────────────────
@api.get("/parts")
def list_parts(request):
    return [part_to_dict(p) for p in Part.objects.all()]


@api.get("/parts/find")
def find_part(request, artnr: str):
    part = Part.objects.filter(artnr__iexact=artnr).first()
    if part is None:
        raise HttpError(404, f"Part '{artnr}' not found")
    return part_to_dict(part)


# ── Modules ──────────────────────────────────────────────────────────────────
@api.get("/modules", response=list[ModuleSchema])
def list_modules(request):
    return list(Module.objects.all())


# ── Resistors ────────────────────────────────────────────────────────────────
@api.get("/resistors", response=list[ResistorSchema])
def list_resistors(request):
    return list(Resistor.objects.all())


# ── Batch info ───────────────────────────────────────────────────────────────
@api.get("/batchinfo", response=list[BatchInfoSchema])
def list_batchinfo(request):
    return list(BatchInfo.objects.all())


@api.get("/batchinfo/{batchnr}", response=BatchInfoSchema)
def get_batchinfo(request, batchnr: int):
    return get_object_or_404(BatchInfo, batchnr=batchnr)


# ── Part details ─────────────────────────────────────────────────────────────
@api.get("/partdetails")
def list_partdetails(request):
    return [part_detail_to_dict(p) for p in PartDetail.objects.all()]


@api.get("/partdetails/find")
def find_partdetail(request, artnr: str):
    detail = PartDetail.objects.filter(artnr__iexact=artnr).first()
    if detail is None:
        raise HttpError(404, f"PartDetail '{artnr}' not found")
    return part_detail_to_dict(detail)
