from rest_framework import serializers

from apps.catalog.models import Bicycle, DockingPoint, Rate, Station


class StationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        fields = ["id", "name", "address", "capacity", "status", "created_at"]
        read_only_fields = ["id", "created_at"]


class BicycleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bicycle
        fields = ["id", "serial_number", "bicycle_type", "status", "created_at"]
        read_only_fields = ["id", "created_at"]


class RateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rate
        fields = ["id", "name", "price", "billing_unit", "is_active"]
        read_only_fields = ["id"]


class DockingPointSerializer(serializers.ModelSerializer):
    class Meta:
        model = DockingPoint
        fields = ["id", "station", "code", "status"]
        read_only_fields = ["id"]
