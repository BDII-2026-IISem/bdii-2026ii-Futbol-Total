from rest_framework import serializers

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
