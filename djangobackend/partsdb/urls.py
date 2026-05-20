"""URL configuration for the partsdb project."""
from __future__ import annotations

from django.http import JsonResponse
from django.urls import path

from parts.api import api


def health(_request):
    return JsonResponse({"status": "healthy"})


urlpatterns = [
    path("api/", api.urls),
    path("health", health),
]
