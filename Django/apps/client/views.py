from rest_framework import viewsets
from rest_framework.permissions import AllowAny

from apps.client.models import Client
from apps.client.serializers import ClientSerializer


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    permission_classes = [AllowAny]
    http_method_names = ["get", "post", "put", "patch", "head", "options"]
    lookup_value_converter = "int"
