from django.test import SimpleTestCase
from django.urls import resolve


class ClientRouteTests(SimpleTestCase):
    def test_collection_route_maps_list_and_create(self):
        route = resolve("/api/clients/")
        self.assertEqual(route.url_name, "client-list")
        self.assertEqual(route.func.actions.get("get"), "list")
        self.assertEqual(route.func.actions.get("post"), "create")

    def test_detail_route_maps_retrieve_update_and_partial_update(self):
        route = resolve("/api/clients/1/")
        self.assertEqual(route.url_name, "client-detail")
        self.assertEqual(route.func.actions.get("get"), "retrieve")
        self.assertEqual(route.func.actions.get("put"), "update")
        self.assertEqual(route.func.actions.get("patch"), "partial_update")
        self.assertNotIn("delete", route.func.cls.http_method_names)
