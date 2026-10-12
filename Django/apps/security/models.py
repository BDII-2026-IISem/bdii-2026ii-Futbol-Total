import hashlib
import string

from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.db import models
from django.utils.crypto import constant_time_compare


class UserManager(BaseUserManager):
    use_in_migrations = True

    def create_user(self, username, password=None, role_id=None, **extra_fields):
        if not username:
            raise ValueError("El nombre de usuario es obligatorio.")
        if role_id is None:
            raise ValueError("role_id es obligatorio para los usuarios PedalLibre.")

        email = extra_fields.get("email")
        extra_fields["email"] = (
            self.normalize_email(email).lower() if email else None
        )

        user = self.model(
            username=username.strip(),
            role_id=role_id,
            **extra_fields,
        )
        user.set_password(password)
        user.save(using=self._db)
        return user


class User(AbstractBaseUser):
    id = models.AutoField(primary_key=True, db_column="user_id")
    role_id = models.IntegerField(db_column="role_id")
    username = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=255, db_column="password_hash")
    email = models.EmailField(
        max_length=150,
        unique=True,
        null=True,
        blank=True,
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(null=True, blank=True)

    last_login = None

    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = ["role_id"]

    objects = UserManager()

    class Meta:
        db_table = "users"
        managed = False
        ordering = ["username"]

    def check_password(self, raw_password):
        encoded_password = self.password or ""

        if len(encoded_password) == 64 and all(
            character in string.hexdigits for character in encoded_password
        ):
            legacy_hash = hashlib.sha256(
                raw_password.encode("utf-8")
            ).hexdigest()

            if not constant_time_compare(
                legacy_hash,
                encoded_password.lower(),
            ):
                return False

            self.set_password(raw_password)
            self.save(update_fields=["password"])
            return True

        return super().check_password(raw_password)

    def __str__(self):
        return self.username