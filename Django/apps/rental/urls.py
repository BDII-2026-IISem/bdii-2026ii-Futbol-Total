from django.urls import path

from apps.rental.views import RentalRegisterAPIView

urlpatterns = [
    path("rentals/", RentalRegisterAPIView.as_view(), name="rental-register"),
]
