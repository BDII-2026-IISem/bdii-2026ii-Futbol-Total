from django.conf import settings
from django.db import models


class Client(models.Model):
    id = models.AutoField(primary_key=True, db_column="client_id")
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.DO_NOTHING,
        db_column="user_id",
        null=True,
        blank=True,
        related_name="client_profile",
    )
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    document_number = models.CharField(max_length=50, unique=True)
    phone = models.CharField(max_length=30, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "clients"
        managed = False

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
