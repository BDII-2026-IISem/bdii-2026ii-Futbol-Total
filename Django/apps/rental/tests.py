import uuid

from django.db import connection
from django.test import TransactionTestCase
from rest_framework.test import APIClient

from apps.catalog.models import Bicycle, DockingPoint, Rate, Station
from apps.client.models import Client as ClientProfile
from apps.rental.models import BicycleDocking, Rental, RentalEvent
from apps.security.models import User


class RentalRegisterTransactionTests(TransactionTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.schema_models = [
            User,
            ClientProfile,
            Station,
            Bicycle,
            Rate,
            DockingPoint,
            BicycleDocking,
            Rental,
            RentalEvent,
        ]
        with connection.schema_editor() as schema_editor:
            for model in cls.schema_models:
                schema_editor.create_model(model)

    @classmethod
    def tearDownClass(cls):
        try:
            with connection.schema_editor() as schema_editor:
                for model in reversed(cls.schema_models):
                    schema_editor.delete_model(model)
        finally:
            super().tearDownClass()

    def setUp(self):
        self.suffix = uuid.uuid4().hex[:12]
        self.api = APIClient()
        self.station = Station.objects.create(
            name=f"Estacion {self.suffix}",
            address="Prueba temporal",
            status="active",
        )
        self.bicycle = Bicycle.objects.create(
            serial_number=f"ISS11-{self.suffix}",
            status="available",
        )
        self.rate = Rate.objects.create(
            name=f"Tarifa {self.suffix}",
            price="5.00",
            billing_unit="minute",
            is_active=True,
        )
        self.point = DockingPoint.objects.create(
            station=self.station,
            code=self.suffix,
            status="available",
        )
        self.docking = BicycleDocking.objects.create(
            bicycle=self.bicycle,
            docking_point=self.point,
        )
        self.client_profile = ClientProfile.objects.create(
            first_name="Cliente",
            last_name="Temporal",
            document_number=f"ISS11-{self.suffix}",
        )

    def payload(self, **overrides):
        data = {
            "clientId": self.client_profile.pk,
            "bicycleId": self.bicycle.pk,
            "rateId": self.rate.pk,
            "startStationId": self.station.pk,
        }
        data.update(overrides)
        return data

    def assert_rejected_without_partial_changes(self, payload=None):
        rentals_before = Rental.objects.count()
        events_before = RentalEvent.objects.count()
        response = self.api.post(
            "/api/rentals/",
            payload or self.payload(),
            format="json",
        )

        self.assertEqual(response.status_code, 400, response.data)
        self.assertEqual(Rental.objects.count(), rentals_before)
        self.assertEqual(RentalEvent.objects.count(), events_before)

        self.bicycle.refresh_from_db()
        self.assertEqual(self.bicycle.status, "available")

        self.docking.refresh_from_db()
        self.assertIsNone(self.docking.undocked_at)

    def test_valid_request_creates_rental_event_and_updates_bicycle(self):
        response = self.api.post(
            "/api/rentals/",
            self.payload(),
            format="json",
        )

        self.assertEqual(response.status_code, 201, response.data)
        rental = Rental.objects.get(pk=response.data["id"])
        self.assertEqual(rental.status, "active")
        self.assertEqual(str(rental.total_amount), "0.00")
        self.assertTrue(
            RentalEvent.objects.filter(
                rental=rental,
                event_type="started",
            ).exists()
        )

        self.bicycle.refresh_from_db()
        self.assertEqual(self.bicycle.status, "rented")

        self.docking.refresh_from_db()
        self.assertIsNotNone(self.docking.undocked_at)

    def test_unavailable_bicycle_is_rejected_without_partial_changes(self):
        self.bicycle.status = "maintenance"
        self.bicycle.save(update_fields=["status"])
        rentals_before = Rental.objects.count()
        events_before = RentalEvent.objects.count()

        response = self.api.post(
            "/api/rentals/",
            self.payload(),
            format="json",
        )

        self.assertEqual(response.status_code, 400, response.data)
        self.assertEqual(Rental.objects.count(), rentals_before)
        self.assertEqual(RentalEvent.objects.count(), events_before)
        self.bicycle.refresh_from_db()
        self.assertEqual(self.bicycle.status, "maintenance")
        self.docking.refresh_from_db()
        self.assertIsNone(self.docking.undocked_at)

    def test_inactive_rate_is_rejected_without_partial_changes(self):
        self.rate.is_active = False
        self.rate.save(update_fields=["is_active"])
        self.assert_rejected_without_partial_changes()

    def test_inactive_station_is_rejected_without_partial_changes(self):
        self.station.status = "inactive"
        self.station.save(update_fields=["status"])
        self.assert_rejected_without_partial_changes()

    def test_inactive_linked_user_is_rejected_without_partial_changes(self):
        user = User.objects.create_user(
            username=f"ISS11-{self.suffix}",
            password="temporal",
            role_id=1,
            is_active=False,
        )
        self.client_profile.user = user
        self.client_profile.save(update_fields=["user"])
        self.assert_rejected_without_partial_changes()

    def test_different_station_from_docking_point_is_rejected(self):
        other_station = Station.objects.create(
            name=f"Otra estacion {self.suffix}",
            address="Prueba temporal",
            status="active",
        )
        self.assert_rejected_without_partial_changes(
            self.payload(startStationId=other_station.pk)
        )

    def test_unavailable_docking_point_is_rejected_without_partial_changes(self):
        self.point.status = "occupied"
        self.point.save(update_fields=["status"])
        self.assert_rejected_without_partial_changes()

    def test_bicycle_without_open_docking_is_rejected_without_partial_changes(self):
        self.docking.delete()
        rentals_before = Rental.objects.count()
        events_before = RentalEvent.objects.count()

        response = self.api.post(
            "/api/rentals/",
            self.payload(),
            format="json",
        )

        self.assertEqual(response.status_code, 400, response.data)
        self.assertEqual(Rental.objects.count(), rentals_before)
        self.assertEqual(RentalEvent.objects.count(), events_before)
        self.bicycle.refresh_from_db()
        self.assertEqual(self.bicycle.status, "available")

    def test_rental_list_includes_registered_rental(self):
        created = self.api.post(
            "/api/rentals/",
            self.payload(),
            format="json",
        )
        self.assertEqual(created.status_code, 201, created.data)

        response = self.api.get("/api/rentals/")
        self.assertEqual(response.status_code, 200, response.data)
        self.assertTrue(
            any(item["id"] == created.data["id"] for item in response.data)
        )

    def test_rental_detail_includes_its_event(self):
        created = self.api.post(
            "/api/rentals/",
            self.payload(),
            format="json",
        )
        self.assertEqual(created.status_code, 201, created.data)

        response = self.api.get(f"/api/rentals/{created.data['id']}/")
        self.assertEqual(response.status_code, 200, response.data)
        self.assertEqual(response.data["status"], "active")
        self.assertEqual(response.data["events"][0]["event_type"], "started")
