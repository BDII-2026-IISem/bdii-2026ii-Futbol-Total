from rest_framework import viewsets
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
