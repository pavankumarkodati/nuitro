from rest_framework import serializers
from .models import CustomUser, OTP, MobileOTP, Workout, WorkoutCompletion
from django.contrib.auth import authenticate
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import InvalidToken

class SignupSerializer(serializers.Serializer):
    phone = serializers.CharField()
    password = serializers.CharField(write_only=True)

class OTPVerifySerializer(serializers.Serializer):
    phone = serializers.CharField()
    otp = serializers.CharField()

class LoginSerializer(serializers.Serializer):
    phone = serializers.CharField()
    password = serializers.CharField(write_only=True)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'phone']


class WorkoutSerializer(serializers.ModelSerializer):
    class Meta:
        model = Workout
        fields = [
            'slug',
            'name',
            'summary',
            'details',
            'information',
            'goals',
            'calories_last_7_days',
            'calories_all_time',
            'calories_average',
            'image_url',
        ]
        read_only_fields = fields

    def to_representation(self, instance):
        data = super().to_representation(instance)

        def _to_float(value):
            try:
                if value in (None, ""):
                    return 0.0
                return float(value)
            except (TypeError, ValueError):
                return 0.0

        for key in (
            'calories_last_7_days',
            'calories_all_time',
            'calories_average',
        ):
            data[key] = _to_float(data.get(key))

        def _as_list(value):
            if isinstance(value, list):
                return value
            if value is None:
                return []
            if isinstance(value, str):
                return [value]
            try:
                return list(value)
            except TypeError:
                return []

        data['information'] = _as_list(data.get('information'))
        data['goals'] = _as_list(data.get('goals'))

        for key in ('summary', 'details', 'image_url'):
            value = data.get(key)
            if value is None:
                data[key] = ""

        return data


class WorkoutCompletionSerializer(serializers.ModelSerializer):
    workout_slug = serializers.CharField(source='workout.slug', read_only=True)
    workout_name = serializers.CharField(source='workout.name', read_only=True)
    calories_kcal = serializers.SerializerMethodField()

    class Meta:
        model = WorkoutCompletion
        fields = ['id', 'workout_slug', 'workout_name', 'calories_kcal', 'completed_at']
        read_only_fields = fields

    def get_calories_kcal(self, obj):
        try:
            return float(obj.calories_kcal)
        except (TypeError, ValueError):
            return 0.0

class CustomTokenSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['phone'] = user.phone
        return token
    
class FoodImageUploadSerializer(serializers.Serializer):
    image = serializers.ImageField(required=True)


class MobileNumberSerializer(serializers.Serializer):
    mobile_number = serializers.CharField(max_length=10)

class OTPVerifySerializer(serializers.Serializer):
    mobile_number = serializers.CharField(max_length=10)
    otp = serializers.CharField(max_length=6)


class CustomTokenRefreshSerializer(serializers.Serializer):
    refresh = serializers.CharField()

    def validate(self, attrs):
        refresh_token = attrs.get('refresh')
        if not refresh_token:
            raise InvalidToken('Refresh token is required')

        try:
            refresh = RefreshToken(refresh_token)
        except Exception as exc:
            raise InvalidToken('Token is invalid or expired') from exc


        refresh.set_jti()
        refresh.set_exp()
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }


class ManualSearchSerializer(serializers.Serializer):
    query = serializers.CharField(max_length=256)


class ManualSaveSerializer(serializers.Serializer):
    query = serializers.CharField(required=False, allow_blank=True)
    selection = serializers.DictField(required=False)


class ManualCaptureSerializer(serializers.Serializer):
    query = serializers.CharField(required=False, allow_blank=True)
    selection = serializers.DictField(required=False)


class VoiceCaptureSerializer(serializers.Serializer):
    transcript = serializers.CharField()


class LogsSearchSerializer(serializers.Serializer):
    query = serializers.CharField(required=False, allow_blank=True)
    limit = serializers.IntegerField(required=False, min_value=1, max_value=50)


class LogsCaptureSerializer(serializers.Serializer):
    query = serializers.CharField(required=False, allow_blank=True)
    selection = serializers.DictField(required=False)


class DietPlanSerializer(serializers.Serializer):
    id = serializers.CharField(required=False, allow_blank=True)
    name = serializers.CharField(max_length=255)
    goal = serializers.CharField(allow_blank=True)
    description = serializers.CharField()
    calories = serializers.IntegerField(min_value=0, required=False)
    macros = serializers.DictField(child=serializers.IntegerField(min_value=0), required=False)
    protein = serializers.IntegerField(min_value=0, required=False)
    carbs = serializers.IntegerField(min_value=0, required=False)
    fat = serializers.IntegerField(min_value=0, required=False)
    fiber = serializers.IntegerField(min_value=0, required=False, allow_null=True)
    water_liters = serializers.FloatField(min_value=0, required=False, allow_null=True)
    intake_text = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    image = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    image_path = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    def validate(self, attrs):
        validated = super().validate(attrs)

        macros = {}
        provided_macros = validated.get('macros') if isinstance(validated.get('macros'), dict) else {}
        macros.update({k: v for k, v in provided_macros.items() if k in {'protein', 'carbs', 'fat'}})

        for key in ('protein', 'carbs', 'fat'):
            if key in validated and validated[key] is not None:
                macros[key] = validated[key]

        missing_macros = [key for key in ('protein', 'carbs', 'fat') if key not in macros]
        if missing_macros:
            raise serializers.ValidationError({
                'macros': f"Missing required macro values: {', '.join(missing_macros)}"
            })

        normalized_macros = {}
        for key, value in macros.items():
            try:
                normalized_macros[key] = max(0, int(value))
            except (TypeError, ValueError):
                raise serializers.ValidationError({
                    'macros': f"Macro '{key}' must be a number"
                })

        validated['macros'] = normalized_macros
        for key in ('protein', 'carbs', 'fat'):
            validated[key] = normalized_macros[key]

        image = validated.get('image')
        image_path = validated.get('image_path')
        if not image and image_path:
            validated['image'] = image_path

        return validated