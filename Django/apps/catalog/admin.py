from django.contrib import admin

from apps.catalog.models import Station


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
