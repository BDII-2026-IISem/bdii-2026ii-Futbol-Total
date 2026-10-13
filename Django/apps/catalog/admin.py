from django.contrib import admin

from apps.catalog.models import Bicycle, DockingPoint, Rate, Station


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


@admin.register(Bicycle)
class BicycleAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "serial_number",
        "bicycle_type",
        "status",
        "created_at",
    )
    list_filter = ("status", "bicycle_type")
    search_fields = ("serial_number",)
    ordering = ("serial_number",)
    readonly_fields = ("id", "created_at")


@admin.register(Rate)
class RateAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "price", "billing_unit", "is_active")
    list_filter = ("is_active", "billing_unit")
    search_fields = ("name",)
    ordering = ("name",)
    readonly_fields = ("id",)
