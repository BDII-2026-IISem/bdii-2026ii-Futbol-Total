from django.contrib import admin

from apps.rental.models import BicycleDocking, Rental, RentalEvent, Reservation


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


@admin.register(RentalEvent)
class RentalEventAdmin(admin.ModelAdmin):
    list_display = ("id", "rental", "event_type", "event_at")
    list_filter = ("event_type", "event_at")
    search_fields = (
        "event_type",
        "description",
        "rental__client__document_number",
        "rental__bicycle__serial_number",
    )
    list_select_related = ("rental", "rental__client", "rental__bicycle")
    ordering = ("-event_at",)
    readonly_fields = (
        "id",
        "rental",
        "event_type",
        "description",
        "event_at",
    )

    def has_view_permission(self, request, obj=None):
        return True

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(BicycleDocking)
class BicycleDockingAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "bicycle",
        "docking_point",
        "docked_at",
        "undocked_at",
    )
    list_filter = ("docked_at", "undocked_at")
    search_fields = (
        "bicycle__serial_number",
        "docking_point__code",
        "docking_point__station__name",
    )
    list_select_related = (
        "bicycle",
        "docking_point",
        "docking_point__station",
    )
    ordering = ("-docked_at",)
    readonly_fields = (
        "id",
        "bicycle",
        "docking_point",
        "docked_at",
        "undocked_at",
    )

    def has_view_permission(self, request, obj=None):
        return True

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False