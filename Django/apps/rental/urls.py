from django.urls import path

from apps.rental.views import (
    RentalDetailAPIView,
    RentalRegisterAPIView,
    ReservationCancelAPIView,
)

urlpatterns = [
    path("rentals/", RentalRegisterAPIView.as_view(), name="rental-register"),
    path(
        "rentals/<int:pk>/",
        RentalDetailAPIView.as_view(),
        name="rental-detail",
    ),
    path(
        "reservations/<int:pk>/",
        ReservationCancelAPIView.as_view(),
        name="reservation-cancel",
    ),
]
