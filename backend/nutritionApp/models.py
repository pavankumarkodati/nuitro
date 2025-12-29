from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone

class UserManager(BaseUserManager):
    def create_user(self, phone, password=None):
        if not phone:
            raise ValueError('Phone number is required')
        user = self.model(phone=phone)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, password):
        user = self.create_user(phone, password)
        user.is_admin = True
        user.is_superuser = True
        user.save(using=self._db)
        return user

class CustomUser(AbstractBaseUser,PermissionsMixin):
    phone = models.CharField(max_length=15, unique=True)
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = []

    objects = UserManager()

    def __str__(self):
        return self.phone

    @property
    def is_staff(self):
        return self.is_admin

class OTP(models.Model):
    phone = models.CharField(max_length=15)
    otp = models.CharField(max_length=4)
    created_at = models.DateTimeField(auto_now_add=True)
class MobileOTP(models.Model):
    mobile_number = models.CharField(max_length=10)
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(default=timezone.now)


class Workout(models.Model):
    slug = models.SlugField(unique=True)
    name = models.CharField(max_length=120, unique=True)
    summary = models.TextField()
    details = models.TextField(blank=True)
    information = models.JSONField(default=list, blank=True)
    goals = models.JSONField(default=list, blank=True)
    calories_last_7_days = models.DecimalField(max_digits=7, decimal_places=1)
    calories_all_time = models.DecimalField(max_digits=7, decimal_places=1)
    calories_average = models.DecimalField(max_digits=7, decimal_places=1)
    image_url = models.URLField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name


class WorkoutCompletion(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="workout_completions")
    workout = models.ForeignKey(Workout, on_delete=models.CASCADE, related_name="completions")
    calories_kcal = models.DecimalField(max_digits=7, decimal_places=1)
    completed_at = models.DateTimeField(default=timezone.now, db_index=True)

    class Meta:
        ordering = ["-completed_at"]
        indexes = [
            models.Index(fields=["user", "completed_at"]),
            models.Index(fields=["workout", "completed_at"]),
        ]

    def __str__(self):
        return f"{self.user_id} · {self.workout.slug} · {self.completed_at.date()}"


class FoodItem(models.Model):
    slug = models.SlugField(max_length=255, unique=True)
    name = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name
