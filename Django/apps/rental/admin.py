from django.contrib import admin

from apps.rental.models import Rental, Reservation


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

    def has_view_permission(self, request, obj=None):
        return True

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False



@admin.register(Rental)
class RentalAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "client",
        "bicycle",
        "rate",
        "started_at",
        "ended_at",
        "status",
        "total_amount",
    )
    list_filter = ("status", "started_at", "rate")
    search_fields = (
        "client__document_number",
        "bicycle__serial_number",
    )
    list_select_related = (
        "client",
        "bicycle",
        "rate",
        "start_station",
        "end_station",
    )
    ordering = ("-started_at",)
    readonly_fields = (
        "id",
        "client",
        "bicycle",
        "rate",
        "start_station",
        "end_station",
        "started_at",
        "ended_at",
        "status",
        "total_amount",
    )

    def has_view_permission(self, request, obj=None):
        return True

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False