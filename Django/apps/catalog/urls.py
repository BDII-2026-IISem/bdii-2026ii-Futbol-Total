from django.urls import path
from rest_framework.routers import SimpleRouter

from apps.catalog.views import (
    BicycleViewSet,
    AvailableBicycleListAPIView,
    DockingPointViewSet,
    RateViewSet,
    StationViewSet,
)


router = SimpleRouter(use_regex_path=False)
router.register("stations", StationViewSet, basename="station")
router.register("bicycles", BicycleViewSet, basename="bicycle")
router.register("rates", RateViewSet, basename="rate")
router.register("docking-points", DockingPointViewSet, basename="docking-point")

urlpatterns = [
    path(
        "bicycles/available/",
        AvailableBicycleListAPIView.as_view(),
        name="bicycle-available",
    ),
]
urlpatterns += router.urls
