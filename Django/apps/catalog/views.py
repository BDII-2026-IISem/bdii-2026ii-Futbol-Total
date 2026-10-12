from rest_framework import viewsets
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny

from apps.catalog.models import Bicycle, DockingPoint, Rate, Station
from apps.catalog.serializers import (
    BicycleSerializer,
    DockingPointSerializer,
    RateSerializer,
    StationSerializer,
)


class CatalogViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]
    http_method_names = ["get", "post", "put", "patch", "head", "options"]
    lookup_value_converter = "int"


class StationViewSet(CatalogViewSet):
    queryset = Station.objects.all()
    serializer_class = StationSerializer


class BicycleViewSet(CatalogViewSet):
    queryset = Bicycle.objects.all()
    serializer_class = BicycleSerializer


class RateViewSet(CatalogViewSet):
    queryset = Rate.objects.all()
    serializer_class = RateSerializer


class DockingPointViewSet(CatalogViewSet):
    queryset = DockingPoint.objects.select_related("station")
    serializer_class = DockingPointSerializer


class AvailableBicycleListAPIView(ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = BicycleSerializer

    def get_queryset(self):
        return Bicycle.objects.filter(
            status="available",
            dockings__undocked_at__isnull=True,
            dockings__docking_point__status="available",
            dockings__docking_point__station__status="active",
        ).distinct()
