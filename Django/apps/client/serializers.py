from rest_framework import serializers

from apps.client.models import Client


class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = [
            "id",
            "user",
            "first_name",
            "last_name",
            "document_number",
            "phone",
            "created_at",
        ]
        read_only_fields = ["id", "created_at"]
