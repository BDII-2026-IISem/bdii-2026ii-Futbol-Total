from django.core.exceptions import ValidationError as DjangoValidationError

from rest_framework import serializers

from apps.catalog.models import Bicycle, Rate, Station
from apps.client.models import Client

from apps.rental.models import BicycleDocking, Rental, RentalEvent, Reservation


class ReservationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reservation
        fields = [
            "id",
            "client",
            "bicycle",
            "station",
            "reserved_at",
            "expires_at",
            "status",
        ]
        read_only_fields = ["id", "reserved_at"]


class RentalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rental
        fields = [
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
        ]
        read_only_fields = ["id", "started_at", "total_amount"]


class RentalEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = RentalEvent
        fields = ["id", "rental", "event_type", "description", "event_at"]
        read_only_fields = ["id", "event_at"]


class BicycleDockingSerializer(serializers.ModelSerializer):
    class Meta:
        model = BicycleDocking
        fields = ["id", "bicycle", "docking_point", "docked_at", "undocked_at"]
        read_only_fields = ["id", "docked_at"]


class RentalRegisterSerializer(serializers.Serializer):
    client_id = serializers.PrimaryKeyRelatedField(
        source="client", queryset=Client.objects.all()
    )
    bicycle_id = serializers.PrimaryKeyRelatedField(
        source="bicycle", queryset=Bicycle.objects.all()
    )
    rate_id = serializers.PrimaryKeyRelatedField(
        source="rate", queryset=Rate.objects.all()
    )
    start_station_id = serializers.PrimaryKeyRelatedField(
        source="start_station", queryset=Station.objects.all()
    )

    def create(self, validated_data):
        try:
            return Rental.objects.register(
                client_id=validated_data["client"].pk,
                bicycle_id=validated_data["bicycle"].pk,
                rate_id=validated_data["rate"].pk,
                start_station_id=validated_data["start_station"].pk,
            )
        except DjangoValidationError as exc:
            raise serializers.ValidationError(exc.message_dict) from exc
