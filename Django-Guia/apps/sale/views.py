from rest_framework import mixins, status, viewsets
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.sale.models import Sale
from apps.sale.serializers import SaleRegisterSerializer, SaleSerializer


class SaleReadViewSet(
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    mixins.DestroyModelMixin,
    viewsets.GenericViewSet,
):
    permission_classes = [AllowAny]
    serializer_class = SaleSerializer
    queryset = Sale.objects.select_related("client").prefetch_related("lines__product")
    lookup_value_converter = "int"

    def perform_destroy(self, instance):
        instance.void()


class SaleRegisterAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SaleRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        sale = serializer.save()
        sale = Sale.objects.prefetch_related("lines__product").get(pk=sale.pk)
        return Response(SaleSerializer(sale).data, status=status.HTTP_201_CREATED)


class SaleCollectionAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, *args, **kwargs):
        queryset = SaleReadViewSet.queryset
        serializer = SaleReadViewSet.serializer_class(queryset, many=True)
        return Response(serializer.data)

    def post(self, request, *args, **kwargs):
        handler = SaleRegisterAPIView()
        handler.request = request
        handler.format_kwarg = None
        handler.args = ()
        handler.kwargs = {}
        return handler.post(request)
