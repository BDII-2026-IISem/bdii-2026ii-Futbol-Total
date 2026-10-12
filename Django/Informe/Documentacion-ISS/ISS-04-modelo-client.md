# ISS-04 - Modelo Client

> **Referencia PedalLibre.** Mapeo de clients: client_id, user_id, first_name, last_name, document_number y phone. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


## Objetivo

Persistir compradores con el diccionario de `clients`.

## Requisitos

- ISS-03 superado.
- Un solo `TextChoices` para `active` e `inactive`.

## Construcción

`apps/common/models.py` es un archivo nuevo y no una app. Contiene los modelos abstractos compartidos:

```python
from django.db import models

from apps.common.status import RecordStatus


class TimeStampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class StoreLabModel(TimeStampedModel):
    status = models.CharField(max_length=8, choices=RecordStatus.choices, default=RecordStatus.INACTIVE)

    class Meta:
        abstract = True

    @classmethod
    def status_constraint(cls, name):
        return models.CheckConstraint(
            condition=models.Q(status__in=RecordStatus.values), name=name
        )
```

Reescriba `apps/client/models.py`:

```python
from django.core.validators import MinLengthValidator
from django.db import models

from apps.common.models import StoreLabModel


class Client(StoreLabModel):
    name = models.CharField(max_length=150, validators=[MinLengthValidator(2)])
    address = models.CharField(max_length=255, null=True, blank=True)
    phone = models.CharField(max_length=30, null=True, blank=True)
    email = models.EmailField(max_length=150, null=True, blank=True, unique=True)

    class Meta:
        db_table = "clients"
        verbose_name = "cliente"
        verbose_name_plural = "clientes"
        ordering = ["name", "id"]
        constraints = [StoreLabModel.status_constraint("clients_status_valid")]

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if self.email:
            self.email = self.email.strip().lower()
        super().save(*args, **kwargs)
```

```bash
python manage.py makemigrations client
python manage.py migrate
```

El serializer del ISS-07 convierte `""` en `None` para que la unicidad de email no choque con cadenas vacías. La prueba HTTP llega en ISS-08.

## Explicación

`MinLengthValidator(2)` vive en el modelo para que API y admin compartan el rango 2-150. `status` por defecto es `inactive`, se heredan los timestamps y el nombre físico se fija como `clients`. El nombre del constraint cabe en el límite histórico de 30 caracteres de Oracle.

## Criterios de aceptación

- AC-04-01: la tabla física es `clients`.
- AC-04-02: un alta sin `status` usa `inactive`.
- AC-04-03: se generan `created_at` y `updated_at`.
- AC-04-04: un email duplicado se rechaza.
- AC-04-05: un nombre de un carácter se rechaza.

## Evidencias y GATE

- EVI-04-01: migración `client.0001_initial` aplicada.
- EVI-04-02: pruebas de cliente PASS.

Los criterios se verifican por la migración, la alta HTTP, timestamps, email duplicado 400 y nombre corto 400.
