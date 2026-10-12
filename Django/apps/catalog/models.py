from django.db import models


class Station(models.Model):
    id = models.AutoField(primary_key=True, db_column="station_id")
    name = models.CharField(max_length=120)
    address = models.CharField(max_length=255)
    capacity = models.PositiveIntegerField(default=0)
    status = models.CharField(max_length=30, default="active")
    created_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "stations"
        managed = False

    def __str__(self):
        return self.name


class Bicycle(models.Model):
    id = models.AutoField(primary_key=True, db_column="bicycle_id")
    serial_number = models.CharField(max_length=80, unique=True)
    bicycle_type = models.CharField(max_length=50, default="standard")
    status = models.CharField(max_length=30, default="available")
    created_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "bicycles"
        managed = False

    def __str__(self):
        return self.serial_number


class Rate(models.Model):
    id = models.AutoField(primary_key=True, db_column="rate_id")
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    billing_unit = models.CharField(max_length=30)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "rates"
        managed = False

    def __str__(self):
        return self.name


class DockingPoint(models.Model):
    id = models.AutoField(primary_key=True, db_column="docking_point_id")
    station = models.ForeignKey(
        Station,
        on_delete=models.DO_NOTHING,
        db_column="station_id",
        related_name="docking_points",
    )
    code = models.CharField(max_length=30)
    status = models.CharField(max_length=30, default="available")

    class Meta:
        db_table = "docking_points"
        managed = False
        constraints = [
            models.UniqueConstraint(
                fields=("station", "code"),
                name="uq_docking_points_code",
            ),
        ]

    def __str__(self):
        return self.code
