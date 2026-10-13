from django.contrib import admin

from apps.client.models import Client


@admin.register(Client)
class ClientAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "first_name",
        "last_name",
        "document_number",
        "phone",
        "user",
        "created_at",
    )
    search_fields = (
        "first_name",
        "last_name",
        "document_number",
        "user__username",
        "user__email",
    )
    list_select_related = ("user",)
    ordering = ("last_name", "first_name")
    readonly_fields = ("id", "created_at")
