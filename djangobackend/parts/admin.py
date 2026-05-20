from django.contrib import admin

from .models import BatchInfo, Module, Part, PartDetail, Resistor

admin.site.register(Part)
admin.site.register(Module)
admin.site.register(Resistor)
admin.site.register(BatchInfo)
admin.site.register(PartDetail)
