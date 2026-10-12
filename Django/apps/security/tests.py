import importlib
import os
from unittest.mock import patch

from django.core.exceptions import ImproperlyConfigured
from django.test import SimpleTestCase

import config.database as database_config


class DatabaseSelectionTests(SimpleTestCase):
    def database_environment(self, dialect):
        return {
            "DB_DIALECT": dialect,
            "DB_MYSQL_NAME": "pedallibre_test",
            "DB_MYSQL_USERNAME": "test_user",
            "DB_MYSQL_PASSWORD": "test_password",
            "DB_MYSQL_HOST": "localhost",
            "DB_MYSQL_PORT": "3306",
            "DB_POSTGRES_NAME": "pedallibre_test",
            "DB_POSTGRES_USERNAME": "test_user",
            "DB_POSTGRES_PASSWORD": "test_password",
            "DB_POSTGRES_HOST": "localhost",
            "DB_POSTGRES_PORT": "5432",
            "DB_MSSQL_NAME": "pedallibre_test",
            "DB_MSSQL_USERNAME": "test_user",
            "DB_MSSQL_PASSWORD": "test_password",
            "DB_MSSQL_HOST": "localhost",
            "DB_MSSQL_PORT": "1433",
            "DB_ORACLE_CONNECT_STRING": "localhost:1521/PEDALIBRE",
            "DB_ORACLE_USERNAME": "test_user",
            "DB_ORACLE_PASSWORD": "test_password",
        }

    def load_database(self, environment):
        with patch.dict(os.environ, environment, clear=True):
            importlib.reload(database_config)
            return database_config.DATABASES["default"].copy()

    def test_each_database_dialect(self):
        expected_engines = {
            "mysql": "django.db.backends.mysql",
            "postgres": "django.db.backends.postgresql",
            "mssql": "mssql",
            "oracle": "django.db.backends.oracle",
        }

        for dialect, expected_engine in expected_engines.items():
            with self.subTest(dialect=dialect):
                database = self.load_database(
                    self.database_environment(dialect)
                )
                self.assertEqual(database["ENGINE"], expected_engine)

    def test_invalid_database_dialect(self):
        environment = {"DB_DIALECT": "sqlite"}

        with patch.dict(os.environ, environment, clear=True):
            with self.assertRaisesRegex(
                ImproperlyConfigured,
                "DB_DIALECT debe ser mysql, postgres, mssql u oracle",
            ):
                importlib.reload(database_config)

    def test_empty_required_database_variable(self):
        environment = self.database_environment("mysql")
        environment["DB_MYSQL_NAME"] = " "

        with patch.dict(os.environ, environment, clear=True):
            with self.assertRaisesRegex(
                ImproperlyConfigured,
                "DB_MYSQL_NAME",
            ):
                importlib.reload(database_config)

    def test_oracle_service_name_connection_string(self):
        environment = self.database_environment("oracle")
        database = self.load_database(environment)

        self.assertEqual(
            database["NAME"],
            "localhost:1521/PEDALIBRE",
        )