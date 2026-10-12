from django.test import SimpleTestCase
from django.urls import resolve


class CatalogRouteTests(SimpleTestCase):
    resources = {
        "stations": "station",
        "bicycles": "bicycle",
        "rates": "rate",
        "docking-points": "docking-point",
    }

    def test_collection_routes_map_list_and_create(self):
        for resource, basename in self.resources.items():
            with self.subTest(resource=resource):
                route = resolve(f"/api/{resource}/")
                self.assertEqual(route.url_name, f"{basename}-list")
                self.assertEqual(route.func.actions.get("get"), "list")
                self.assertEqual(route.func.actions.get("post"), "create")

    def test_detail_routes_map_retrieve_update_and_disable_delete(self):
        for resource, basename in self.resources.items():
            with self.subTest(resource=resource):
                route = resolve(f"/api/{resource}/1/")
                self.assertEqual(route.url_name, f"{basename}-detail")
                self.assertEqual(route.func.actions.get("get"), "retrieve")
                self.assertEqual(route.func.actions.get("put"), "update")
                self.assertEqual(route.func.actions.get("patch"), "partial_update")
                self.assertNotIn("delete", route.func.cls.http_method_names)
