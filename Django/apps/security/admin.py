from django.contrib import admin

from apps.security.models import User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "username",
        "role_id",
        "email",
        "is_active",
        "created_at",
    )
    list_filter = ("is_active", "role_id")
    search_fields = ("username", "email")
    ordering = ("username",)
    fields = (
        "id",
        "username",
        "role_id",
        "email",
        "is_active",
        "created_at",
    )
    readonly_fields = fields

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
