from decimal import Decimal

from django.db import models
from django.utils import timezone

from apps.catalog.models import Bicycle, DockingPoint, Rate, Station
from apps.client.models import Client
from apps.rental.managers import RentalManager


class Reservation(models.Model):
    id = models.AutoField(primary_key=True, db_column="reservation_id")
    client = models.ForeignKey(
        Client,
        on_delete=models.DO_NOTHING,
        db_column="client_id",
        related_name="reservations",
    )
    bicycle = models.ForeignKey(
        Bicycle,
        on_delete=models.DO_NOTHING,
        db_column="bicycle_id",
        related_name="reservations",
    )
    station = models.ForeignKey(
        Station,
        on_delete=models.DO_NOTHING,
        db_column="station_id",
        related_name="reservations",
    )
    reserved_at = models.DateTimeField(default=timezone.now)
    expires_at = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=30, default="pending")

    class Meta:
        db_table = "reservations"
        managed = False


class Rental(models.Model):
    id = models.AutoField(primary_key=True, db_column="rental_id")
    client = models.ForeignKey(
        Client,
        on_delete=models.DO_NOTHING,
        db_column="client_id",
        related_name="rentals",
    )
    bicycle = models.ForeignKey(
        Bicycle,
        on_delete=models.DO_NOTHING,
        db_column="bicycle_id",
        related_name="rentals",
    )
    rate = models.ForeignKey(
        Rate,
        on_delete=models.DO_NOTHING,
        db_column="rate_id",
        related_name="rentals",
    )
    start_station = models.ForeignKey(
        Station,
        on_delete=models.DO_NOTHING,
        db_column="start_station_id",
        null=True,
        blank=True,
        related_name="starting_rentals",
    )
    end_station = models.ForeignKey(
        Station,
        on_delete=models.DO_NOTHING,
        db_column="end_station_id",
        null=True,
        blank=True,
        related_name="ending_rentals",
    )
    started_at = models.DateTimeField(default=timezone.now)
    ended_at = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=30, default="active")
    total_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal("0.00"),
    )

    objects = RentalManager()

    class Meta:
        db_table = "rentals"
        managed = False


class RentalEvent(models.Model):
    id = models.AutoField(primary_key=True, db_column="rental_event_id")
    rental = models.ForeignKey(
        Rental,
        on_delete=models.DO_NOTHING,
        db_column="rental_id",
        related_name="events",
    )
    event_type = models.CharField(max_length=50)
    description = models.CharField(max_length=500, null=True, blank=True)
    event_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "rental_events"
        managed = False


class BicycleDocking(models.Model):
    id = models.AutoField(primary_key=True, db_column="bicycle_docking_id")
    bicycle = models.ForeignKey(
        Bicycle,
        on_delete=models.DO_NOTHING,
        db_column="bicycle_id",
        related_name="dockings",
    )
    docking_point = models.ForeignKey(
        DockingPoint,
        on_delete=models.DO_NOTHING,
        db_column="docking_point_id",
        related_name="bicycle_dockings",
    )
    docked_at = models.DateTimeField(default=timezone.now)
    undocked_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "bicycle_dockings"
        managed = False
