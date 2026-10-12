from rest_framework.routers import SimpleRouter

from apps.catalog.views import (
    BicycleViewSet,
    DockingPointViewSet,
    RateViewSet,
    StationViewSet,
)


router = SimpleRouter(use_regex_path=False)
router.register("stations", StationViewSet, basename="station")
router.register("bicycles", BicycleViewSet, basename="bicycle")
router.register("rates", RateViewSet, basename="rate")
router.register("docking-points", DockingPointViewSet, basename="docking-point")

urlpatterns = router.urls
