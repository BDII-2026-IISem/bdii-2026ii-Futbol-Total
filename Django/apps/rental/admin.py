from django.contrib import admin

from apps.rental.models import Reservation


@admin.register(Reservation)
class ReservationAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "client",
        "bicycle",
        "station",
        "reserved_at",
        "expires_at",
        "status",
    )
    list_filter = ("status", "reserved_at")
    search_fields = (
        "client__document_number",
        "bicycle__serial_number",
        "station__name",
    )
    list_select_related = ("client", "bicycle", "station")
    ordering = ("-reserved_at",)
    readonly_fields = (
        "id",
        "client",
        "bicycle",
        "station",
        "reserved_at",
        "expires_at",
        "status",
    )

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
