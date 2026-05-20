"""Database models mirroring the .NET DTOs in webbackend/Models/."""
from __future__ import annotations

from django.db import models


class Part(models.Model):
    batch = models.IntegerField()
    artnr = models.CharField(max_length=255, db_index=True)
    description = models.TextField(blank=True, default="")
    stock = models.IntegerField(null=True, blank=True)
    # `class` is a Python reserved word; store under db_column='class' to
    # preserve the JSON field name expected by Angular.
    klass = models.CharField(max_length=255, null=True, blank=True, db_column="class")
    value1 = models.CharField(max_length=255, null=True, blank=True)
    value2 = models.CharField(max_length=255, null=True, blank=True)
    mark = models.CharField(max_length=255, null=True, blank=True)

    class Meta:
        db_table = "parts"

    def __str__(self) -> str:
        return f"{self.artnr} (batch {self.batch})"


class Module(models.Model):
    artnr = models.CharField(max_length=255, db_index=True)
    description = models.TextField(blank=True, default="")
    stock = models.IntegerField(default=0)

    class Meta:
        db_table = "modules"

    def __str__(self) -> str:
        return self.description or self.artnr


class Resistor(models.Model):
    # JSON field name is `f_value` already; column name kept consistent.
    f_value = models.CharField(max_length=64, db_column="f_value")
    value = models.CharField(max_length=64)
    tolerance = models.CharField(max_length=64)
    comment = models.CharField(max_length=255, blank=True, default="")

    class Meta:
        db_table = "resistors"

    def __str__(self) -> str:
        return f"{self.value} Ω ±{self.tolerance}%"


class BatchInfo(models.Model):
    batchnr = models.IntegerField(primary_key=True)
    # Stored as string to preserve the exact wire format ("2014-04-16").
    orderdate = models.CharField(max_length=32)

    class Meta:
        db_table = "batchinfo"

    def __str__(self) -> str:
        return f"Batch {self.batchnr} ({self.orderdate})"


class PartDetail(models.Model):
    artnr = models.CharField(max_length=255, db_index=True)
    description = models.TextField(blank=True, default="")
    stock = models.IntegerField(null=True, blank=True)
    klass = models.CharField(max_length=255, null=True, blank=True, db_column="class")

    class Meta:
        db_table = "partdetails"

    def __str__(self) -> str:
        return self.artnr
