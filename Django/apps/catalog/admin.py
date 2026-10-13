from django.contrib import admin

from apps.catalog.models import DockingPoint, Station


@admin.register(Station)
class StationAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "name",
        "address",
        "capacity",
        "status",
        "created_at",
    )
    list_filter = ("status",)
    search_fields = ("name", "address")
    ordering = ("name",)
    readonly_fields = ("id", "created_at")


@admin.register(DockingPoint)
class DockingPointAdmin(admin.ModelAdmin):
    list_display = ("id", "code", "station", "status")
    list_filter = ("status", "station")
    search_fields = ("code", "station__name")
    list_select_related = ("station",)
    ordering = ("station__name", "code")
    readonly_fields = ("id",)
