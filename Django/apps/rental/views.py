from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.rental.serializers import RentalRegisterSerializer, RentalSerializer


class RentalRegisterAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RentalRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        rental = serializer.save()
        return Response(RentalSerializer(rental).data, status=status.HTTP_201_CREATED)
