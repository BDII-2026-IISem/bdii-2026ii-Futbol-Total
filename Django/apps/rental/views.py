from django.shortcuts import get_object_or_404

from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.rental.models import Rental
from apps.rental.serializers import (
    RentalReadSerializer,
    RentalRegisterSerializer,
    RentalSerializer,
)


class RentalRegisterAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        rentals = Rental.objects.select_related(
            "client", "bicycle", "rate", "start_station", "end_station"
        ).prefetch_related("events").order_by("pk")
        serializer = RentalReadSerializer(rentals, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = RentalRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        rental = serializer.save()
        return Response(RentalSerializer(rental).data, status=status.HTTP_201_CREATED)


class RentalDetailAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, pk):
        rentals = Rental.objects.select_related(
            "client", "bicycle", "rate", "start_station", "end_station"
        ).prefetch_related("events")
        rental = get_object_or_404(rentals, pk=pk)
        serializer = RentalReadSerializer(rental)
        return Response(serializer.data)
