from decimal import Decimal

from django.core.exceptions import ValidationError
from django.db import models, transaction
from django.utils import timezone


class RentalQuerySet(models.QuerySet):
    def register(self, *, client_id, bicycle_id, rate_id, start_station_id):
        from apps.catalog.models import Bicycle, Rate, Station
        from apps.client.models import Client
        from apps.rental.models import BicycleDocking, Rental, RentalEvent

        with transaction.atomic():
            client = Client.objects.select_for_update().select_related("user").get(
                pk=client_id
            )
            bicycle = Bicycle.objects.select_for_update().get(pk=bicycle_id)
            rate = Rate.objects.select_for_update().get(pk=rate_id)
            station = Station.objects.select_for_update().get(pk=start_station_id)

            docking = (
                BicycleDocking.objects.select_for_update()
                .select_related("docking_point")
                .filter(bicycle_id=bicycle.pk, undocked_at__isnull=True)
                .order_by("pk")
                .first()
            )

            if client.user_id and not client.user.is_active:
                raise ValidationError(
                    {"clientId": ["El usuario del cliente está inactivo."]}
                )
            if bicycle.status != "available":
                raise ValidationError(
                    {"bicycleId": ["La bicicleta no está disponible."]}
                )
            if not rate.is_active:
                raise ValidationError({"rateId": ["La tarifa no está activa."]})
            if station.status != "active":
                raise ValidationError(
                    {"startStationId": ["La estación no está activa."]}
                )
            if docking is None:
                raise ValidationError(
                    {"bicycleId": ["La bicicleta no está anclada."]}
                )
            if docking.docking_point.status != "available":
                raise ValidationError(
                    {"bicycleId": ["El punto de anclaje no está disponible."]}
                )
            if docking.docking_point.station_id != station.pk:
                raise ValidationError(
                    {
                        "startStationId": [
                            "La bicicleta no está en la estación indicada."
                        ]
                    }
                )

            started_at = timezone.now()
            rental = Rental.objects.create(
                client=client,
                bicycle=bicycle,
                rate=rate,
                start_station=station,
                started_at=started_at,
                status="active",
                total_amount=Decimal("0.00"),
            )
            RentalEvent.objects.create(
                rental=rental,
                event_type="started",
                description="Alquiler iniciado desde la API.",
                event_at=started_at,
            )

            docking.undocked_at = started_at
            docking.save(update_fields=["undocked_at"])

            bicycle.status = "rented"
            bicycle.save(update_fields=["status"])

            return rental


class RentalManager(models.Manager.from_queryset(RentalQuerySet)):
    pass
