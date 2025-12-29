from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser
from .models import CustomUser, OTP,MobileOTP, Workout, WorkoutCompletion
from .serializers import (
    SignupSerializer,
    OTPVerifySerializer,
    LoginSerializer,
    UserSerializer,
    CustomTokenSerializer,
    FoodImageUploadSerializer,
    CustomTokenRefreshSerializer,
    ManualSearchSerializer,
    ManualSaveSerializer,
    ManualCaptureSerializer,
    VoiceCaptureSerializer,
    LogsSearchSerializer,
    LogsCaptureSerializer,
    DietPlanSerializer,
    WorkoutSerializer,
    WorkoutCompletionSerializer,
)
import random,smtplib
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.hashers import check_password
from typing import Optional, List, Dict, Any, Tuple
import csv
import ast
from collections import defaultdict
from html import unescape
try:
    from pyzbar import pyzbar
    PYZBARD_AVAILABLE = True
except ImportError:
    PYZBARD_AVAILABLE = False
    pyzbar = None
User = get_user_model()
from rest_framework_simplejwt.views import TokenObtainPairView, TokenViewBase
from rest_framework_simplejwt.tokens import RefreshToken, AccessToken
from rest_framework import serializers
from rest_framework_simplejwt.exceptions import InvalidToken
from django.utils.timezone import now, make_aware
from django.core.files.base import ContentFile
# Removed duplicate get_user_id_from_token function - keeping the one at line 67
import requests
import os
from google import genai
from google.genai import types
from dotenv import load_dotenv
import re
import json
from django.core.files.storage import default_storage
from django.core.cache import cache
from pymongo import MongoClient
from bson.binary import Binary
from django.utils import timezone
import numpy as np
import cv2
from django.contrib.auth.hashers import make_password
import string
from datetime import datetime, timedelta, date
import math
import hashlib
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
# MongoDB connection
from pymongo import MongoClient
import urllib.parse

from django.views import View
from django.shortcuts import render
import traceback
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.exceptions import InvalidToken
import uuid


load_dotenv()
# api_user_token = os.getenv("LOGMEAL_API_TOKEN")
api_key=os.getenv("GEMINE_API_KEY")
genai_client =  genai.Client(api_key=api_key)
EMAIL_USER=os.getenv("EMAIL_USER")
EMAIL_PW=os.getenv("EMAIL_PASS")
# MongoDB credentials
username = ""
password = ""

encoded_username = urllib.parse.quote_plus(username)
encoded_password = urllib.parse.quote_plus(password)

uri =f"mongodb+srv://{encoded_username}:{encoded_password}@cluster0.zaytioc.mongodb.net/nutrition-app?retryWrites=true&w=majority"

DEFAULT_WELLNESS_QUESTION = "How are you feeling today?"
DEFAULT_WELLNESS_OPTIONS = ["Happy 😊", "Low 😔", "Sick 🤢", "Energetic ⚡"]


mongo_client = MongoClient(uri)
db = mongo_client["nutrition-app"]
img_store_collection = db['img-store']
user_activity_collection = db['user_activity']
user_info_collection=db['user-info']
otp_collection=db['Email_Otp']

FOOD_DATABASE_PATH = os.path.join(os.path.dirname(__file__), "fooddatabase.txt")
_FOOD_DB_CACHE: Dict[str, Any] = {"mtime": None, "items": None}

SAMPLE_FOOD_LIBRARY = [
    {
        "name": "Grilled Chicken Salad",
        "description": "Grilled chicken breast with mixed greens, cherry tomatoes, and vinaigrette dressing.",
        "calories": 410,
        "macros": {"protein": 36, "carbs": 18, "fat": 18},
        "keywords": ["chicken", "salad", "grilled"],
    },
    {
        "name": "Overnight Oats",
        "description": "Rolled oats soaked in almond milk with chia seeds, banana, and berries.",
        "calories": 320,
        "macros": {"protein": 12, "carbs": 52, "fat": 8},
        "keywords": ["oat", "breakfast", "berries"],
    },
    {
        "name": "Veggie Omelette",
        "description": "Three-egg omelette filled with spinach, mushrooms, and bell peppers.",
        "calories": 280,
        "macros": {"protein": 20, "carbs": 8, "fat": 18},
        "keywords": ["omelette", "egg", "breakfast"],
    },
    {
        "name": "Quinoa Power Bowl",
        "description": "Quinoa with roasted sweet potato, black beans, avocado, and cilantro lime dressing.",
        "calories": 520,
        "macros": {"protein": 18, "carbs": 64, "fat": 20},
        "keywords": ["quinoa", "bowl", "vegan"],
    },
]


def _macros_to_fraction(macros: Dict[str, float]) -> Dict[str, float]:
    protein = max(0.0, safe_float(macros.get("protein")))
    carbs = max(0.0, safe_float(macros.get("carbs")))
    fat = max(0.0, safe_float(macros.get("fat")))
    total = protein + carbs + fat
    if total <= 0:
        return {"protein": 0.0, "carbs": 0.0, "fat": 0.0}
    return {
        "protein": round(protein / total, 4),
        "carbs": round(carbs / total, 4),
        "fat": round(fat / total, 4),
    }


def _build_foodlog_payload(
    name: str,
    calories: float,
    macros: Optional[Dict[str, float]] = None,
    description: Optional[str] = None,
    serving_size: str = "1 serving",
    image_url: Optional[str] = None,
    meal: Optional[str] = None,
) -> Dict[str, Any]:
    macros = macros or {}
    fractions = _macros_to_fraction(macros)
    calories_value = int(round(max(0.0, safe_float(calories))))
    payload = {
        "food_name": name,
        "serving_size": serving_size,
        "nutrition_data": {
            "energy": calories_value,
            "calories": calories_value,
            "protein": safe_float(macros.get("protein")),
            "carbs": safe_float(macros.get("carbs")),
            "fat": safe_float(macros.get("fat")),
        },
        "meal_info": {
            "meal": meal or "Meal",
            "calories": calories_value,
            "protein": fractions["protein"],
            "carbs": fractions["carbs"],
            "fat": fractions["fat"],
        },
        "captured_at": datetime.utcnow().isoformat(),
    }
    if image_url:
        payload["image_url"] = image_url
    if description:
        payload["description"] = description
    return payload


def _build_food_description(foodlog: Dict[str, Any]) -> str:
    nutrition = foodlog.get("nutrition_data", {}) if isinstance(foodlog, dict) else {}
    meal_info = foodlog.get("meal_info", {}) if isinstance(foodlog, dict) else {}
    calories = safe_float(meal_info.get("calories") or nutrition.get("calories") or nutrition.get("energy"))
    description = f"{int(round(calories))} kcal" if calories else ""
    macros = []
    for key in ("protein", "carbs", "fat"):
        value = safe_float(nutrition.get(key))
        if value:
            macros.append(f"{key.capitalize()}: {value:.1f} g")
    if macros:
        description = f"{description} | {', '.join(macros)}" if description else ", ".join(macros)
    return description or "No nutrition details"

def _parse_timestamp(value: Any) -> datetime:
    if isinstance(value, datetime):
        return value
    if isinstance(value, (int, float)):
        try:
            # Heuristic: treat very large numbers as milliseconds
            if value > 1e12:
                return datetime.utcfromtimestamp(value / 1000.0)
            return datetime.utcfromtimestamp(value)
        except Exception:
            return datetime.utcnow()
    if isinstance(value, str):
        text = value.strip()
        if not text:
            return datetime.utcnow()
        try:
            if text.endswith("Z"):
                text = text[:-1] + "+00:00"
            return datetime.fromisoformat(text)
        except Exception:
            for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d"):
                try:
                    return datetime.strptime(text, fmt)
                except Exception:
                    continue
    return datetime.utcnow()


def _to_iso_datetime(value: Any) -> str:
    if isinstance(value, datetime):
        return value.replace(microsecond=0).isoformat()
    if isinstance(value, str) and value.strip():
        return value
    parsed = _parse_timestamp(value)
    return parsed.replace(microsecond=0).isoformat()


def _to_iso_date(value: Any) -> Optional[str]:
    if value is None:
        return None
    parsed = _parse_timestamp(value)
    return parsed.date().isoformat()


def _collect_user_foodlogs(user_id: str) -> List[Tuple[Optional[str], Dict[str, Any]]]:
    user_doc = user_activity_collection.find_one({"user_id": user_id})
    collected: List[Tuple[Optional[str], Dict[str, Any]]] = []
    if not isinstance(user_doc, dict):
        return collected
    logs = user_doc.get("logs") or []
    if not isinstance(logs, list):
        return collected
    for log in logs:
        if not isinstance(log, dict):
            continue
        date_str = log.get("date")
        entries = log.get("entries") or []
        if not isinstance(entries, list):
            continue
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            foodlog = entry.get("foodlog")
            if isinstance(foodlog, dict):
                collected.append((date_str, foodlog))
    return collected


def _search_user_food_entries(user_id: str, query: str, limit: int = 10) -> List[Dict[str, Any]]:
    query_lower = (query or "").strip().lower()
    entries: List[Dict[str, Any]] = []
    seen: set = set()
    collected = sorted(
        _collect_user_foodlogs(user_id),
        key=lambda item: item[0] or "",
        reverse=True,
    )
    for date_str, foodlog in collected:
        name = str(foodlog.get("food_name") or "Food item").strip()
        description = _build_food_description(foodlog)
        haystack = f"{name} {description}".lower()
        if query_lower and query_lower not in haystack:
            continue
        key = json.dumps(foodlog, sort_keys=True, default=str)
        if key in seen:
            continue
        seen.add(key)
        entry = {
            "name": name or "Food item",
            "description": description,
            "foodlog": foodlog,
            "source": "history",
        }
        if date_str:
            entry["logged_date"] = date_str
        entries.append(entry)
        if len(entries) >= limit:
            break
    return entries


def _load_food_database() -> List[str]:
    try:
        stat = os.stat(FOOD_DATABASE_PATH)
    except FileNotFoundError:
        print('[ManualLogSearch][FOOD_DB_ERR] fooddatabase.txt not found', flush=True)
        return []
    except Exception as exc:
        print('[ManualLogSearch][FOOD_DB_ERR]', str(exc), flush=True)
        return []

    cached = _FOOD_DB_CACHE
    mtime = stat.st_mtime
    if cached["items"] is not None and cached["mtime"] == mtime:
        return cached["items"] or []

    items: List[str] = []

    def _consume(raw: str):
        candidate = raw.strip()
        if not candidate:
            return
        candidate = candidate.strip('[]')
        if not candidate:
            return
        if candidate.endswith(','):
            candidate = candidate[:-1].strip()
        if not candidate:
            return

        def _append_value(value: Any):
            if isinstance(value, str):
                cleaned_item = unescape(value.strip())
                if cleaned_item:
                    items.append(cleaned_item)

        parsed = False
        for loader in (json.loads, ast.literal_eval):
            try:
                value = loader(candidate)
            except Exception:
                continue
            parsed = True
            if isinstance(value, list):
                for element in value:
                    _append_value(element)
            else:
                _append_value(value)
            break

        if parsed:
            return

        # Fallback: split via CSV to catch trailing fragments
        try:
            parsed_rows = list(csv.reader([candidate], delimiter=',', quotechar='"'))
        except Exception:
            parsed_rows = [[candidate]]
        for row in parsed_rows:
            for field in row:
                _append_value(field)

    try:
        with open(FOOD_DATABASE_PATH, "r", encoding="utf-8") as handle:
            inside = False
            for raw_line in handle:
                line = raw_line.strip()
                if not inside:
                    bracket_index = line.find('[')
                    if bracket_index != -1:
                        inside = True
                        remainder = line[bracket_index + 1:]
                        if remainder:
                            closing_index = remainder.find(']')
                            if closing_index != -1:
                                segment = remainder[:closing_index]
                                _consume(segment)
                                inside = False
                            else:
                                _consume(remainder)
                    continue

                closing_index = line.find(']')
                if closing_index != -1:
                    segment = line[:closing_index]
                    _consume(segment)
                    inside = False
                    continue

                _consume(line)
    except Exception as exc:
        print('[ManualLogSearch][FOOD_DB_PARSE_ERR]', str(exc), flush=True)
        return []

    cached["items"] = items
    cached["mtime"] = mtime
    return items


def _search_food_database(query: str, limit: int = 15) -> List[Dict[str, Any]]:
    names = _load_food_database()
    if not names:
        return []

    query_lower = (query or "").strip().lower()
    if not query_lower:
        top = names[:limit]
        return [
            {
                "name": name,
                "description": "",
                "foodlog": _build_foodlog_payload(name=name, calories=0),
                "source": "database",
            }
            for name in top
        ]

    matches: List[Tuple[int, int, str]] = []
    for index, name in enumerate(names):
        name_lower = name.lower()
        if query_lower in name_lower:
            distance = abs(len(name_lower) - len(query_lower))
            matches.append((distance, index, name))

    matches.sort(key=lambda item: (item[0], item[1]))

    suggestions = []
    for _, _, name in matches[:limit]:
        payload = _build_foodlog_payload(name=name, calories=0)
        suggestions.append({
            "name": name,
            "description": "",
            "foodlog": payload,
            "source": "database",
        })
    return suggestions


def _search_sample_foods(query: str, limit: int = 10) -> List[Dict[str, Any]]:
    query_lower = (query or "").strip().lower()
    matches: List[Dict[str, Any]] = []
    for item in SAMPLE_FOOD_LIBRARY:
        keywords = " ".join(item.get("keywords", []))
        if query_lower and query_lower not in item["name"].lower() and query_lower not in keywords.lower():
            continue
        payload = _build_foodlog_payload(
            name=item["name"],
            calories=item.get("calories", 0),
            macros=item.get("macros", {}),
            description=item.get("description"),
        )
        matches.append(
            {
                "name": item["name"],
                "description": item.get("description"),
                "foodlog": payload,
                "source": "sample",
            }
        )
        if len(matches) >= limit:
            break
    if not matches:
        # fallback to first N items
        for item in SAMPLE_FOOD_LIBRARY[:limit]:
            payload = _build_foodlog_payload(
                name=item["name"],
                calories=item.get("calories", 0),
                macros=item.get("macros", {}),
                description=item.get("description"),
            )
            matches.append(
                {
                    "name": item["name"],
                    "description": item.get("description"),
                    "foodlog": payload,
                    "source": "sample",
                }
            )
            if len(matches) >= limit:
                break
    return matches


def _normalize_captured_time(value: Any, date_str: Optional[str] = None) -> Tuple[Optional[str], Optional[str]]:
    iso_value: Optional[str] = None
    parsed: Optional[datetime] = None

    if isinstance(value, datetime):
        parsed = value
        iso_value = value.isoformat()
    elif isinstance(value, str):
        iso_value = value
        candidate = value.strip()
        if candidate:
            if candidate.endswith('Z'):
                candidate = candidate[:-1] + '+00:00'
            try:
                parsed = datetime.fromisoformat(candidate)
            except Exception:
                parsed = None
    elif value is not None:
        try:
            parsed = datetime.fromtimestamp(float(value))
            iso_value = parsed.isoformat()
        except Exception:
            parsed = None

    if parsed is None and date_str:
        try:
            parsed = datetime.strptime(date_str, "%Y-%m-%d")
        except Exception:
            parsed = None

    display = None
    if parsed is not None:
        display = parsed.strftime("%I:%M %p").lstrip('0')
        if not iso_value:
            iso_value = parsed.isoformat()

    return iso_value, display


def _build_foodlog_entry(
    foodlog: Dict[str, Any],
    date_str: Optional[str] = None,
    source: Optional[str] = None,
) -> Dict[str, Any]:
    foodlog = foodlog or {}
    name = str(foodlog.get("food_name") or "Food item")
    meal_info = foodlog.get("meal_info") if isinstance(foodlog, dict) else {}
    if not isinstance(meal_info, dict):
        meal_info = {}
    nutrition = foodlog.get("nutrition_data") if isinstance(foodlog, dict) else {}
    if not isinstance(nutrition, dict):
        nutrition = {}

    meal_label = str(meal_info.get("meal") or meal_info.get("meal_type") or "").strip()
    calories = safe_float(meal_info.get('calories') or nutrition.get('calories') or nutrition.get('energy'))
    macros = extract_macros(foodlog)
    description = _build_food_description(foodlog)

    captured_raw = foodlog.get("captured_at") or meal_info.get("captured_at")
    captured_iso, captured_display = _normalize_captured_time(captured_raw, date_str)

    resolved_source = source or foodlog.get('source') or meal_info.get('source') or 'history'

    try:
        fingerprint = json.dumps(foodlog, sort_keys=True, default=str)
    except Exception:
        fingerprint = str(foodlog)
    entry_id = hashlib.sha1(fingerprint.encode('utf-8', 'ignore')).hexdigest()

    safe_foodlog = json.loads(json.dumps(foodlog, default=str))

    entry = {
        'id': entry_id,
        'name': name,
        'meal': meal_label,
        'description': description,
        'calories': round(calories, 2),
        'macros': {
            'carbs': round(macros.get('carbs', 0.0), 2),
            'protein': round(macros.get('protein', 0.0), 2),
            'fat': round(macros.get('fat', 0.0), 2),
        },
        'captured_at': captured_iso,
        'captured_display': captured_display,
        'source': resolved_source,
        'foodlog': safe_foodlog,
    }

    if date_str:
        entry['date'] = date_str

    return entry


def _foodlog_from_selection(selection: Optional[Dict[str, Any]], fallback_name: str) -> Dict[str, Any]:
    selection = selection or {}
    if isinstance(selection.get("foodlog"), dict):
        payload = dict(selection["foodlog"])
    else:
        macros = {
            "protein": selection.get("protein"),
            "carbs": selection.get("carbs"),
            "fat": selection.get("fat"),
        }
        calories = selection.get("calories") or selection.get("energy")
        payload = _build_foodlog_payload(
            name=selection.get("name") or fallback_name or "Food item",
            calories=calories or 0,
            macros=macros,
            description=selection.get("description"),
            serving_size=selection.get("serving_size") or "1 serving",
            meal=selection.get("meal"),
        )
    if not payload.get("food_name"):
        payload["food_name"] = fallback_name or "Food item"
    if "captured_at" not in payload:
        payload["captured_at"] = datetime.utcnow().isoformat()
    return payload


def _append_foodlog_entry(
    user_id: str,
    food_payload: Dict[str, Any],
    date_str: Optional[str] = None,
    metadata: Optional[Dict[str, Any]] = None,
) -> str:
    date_str = date_str or now().strftime("%Y-%m-%d")
    entry = {"foodlog": food_payload}
    if metadata:
        entry["meta"] = metadata

    user_doc = user_activity_collection.find_one({"user_id": user_id})
    if user_doc:
        logs_list = user_doc.get("logs") or []
        if not isinstance(logs_list, list):
            logs_list = []
        log_found = False
        for log in logs_list:
            if isinstance(log, dict) and log.get("date") == date_str:
                log.setdefault("entries", []).append(entry)
                log_found = True
                break
        if not log_found:
            logs_list.append({
                "date": date_str,
                "entries": [entry],
            })
        user_activity_collection.update_one({"user_id": user_id}, {"$set": {"logs": logs_list}})
    else:
        user_activity_collection.insert_one({
            "user_id": user_id,
            "logs": [
                {
                    "date": date_str,
                    "entries": [entry]
                }
            ]
        })

    return date_str

# ---------------------------------------------------------------------------
# Progress analytics helpers
# ---------------------------------------------------------------------------

PERIOD_TO_DAYS = {
# {{ ... }}
    'daily': 1,
    'weekly': 7,
    'monthly': 30,
    'quarterly': 90,
}


def parse_period(raw_period: str) -> str:
    period = (raw_period or 'daily').lower()
    return period if period in PERIOD_TO_DAYS else 'daily'


def clamp_date_range(period: str, start: Optional[str], end: Optional[str]) -> (date, date):
    """Resolve a sane start/end range for the given period.
    - If no start is provided, expand to the last N days for the period ending at end/today.
    - If a start is provided, clamp to at most N days.
    """
    try:
        end_date = datetime.strptime(end, "%Y-%m-%d").date() if end else date.today()
    except Exception:
        end_date = date.today()

    max_days = PERIOD_TO_DAYS.get(period, 7)

    if start:
        try:
            start_date = datetime.strptime(start, "%Y-%m-%d").date()
        except Exception:
            start_date = end_date
        # Clamp to at most max_days window
        if (end_date - start_date).days >= max_days:
            start_date = end_date - timedelta(days=max_days - 1)
    else:
        # No explicit start: expand to the full period window ending at end_date
        start_date = end_date - timedelta(days=max_days - 1)

    if start_date > end_date:
        start_date, end_date = end_date, start_date

    return start_date, end_date


def daterange(start_date: date, end_date: date):
    for n in range((end_date - start_date).days + 1):
        yield start_date + timedelta(n)


def safe_float(value) -> float:
    try:
        if value is None:
            return 0.0
        if isinstance(value, (int, float)):
            if isinstance(value, float) and (math.isnan(value) or math.isinf(value)):
                return 0.0
            return float(value)
        if isinstance(value, str):
            return float(value.strip())
    except Exception:
        return 0.0
    return 0.0


def extract_meal_calories(foodlog: Dict[str, Any]) -> Dict[str, float]:
    meal_info = foodlog.get('meal_info', {}) if isinstance(foodlog, dict) else {}
    calories = safe_float(meal_info.get('calories') or foodlog.get('calories'))
    protein = safe_float(meal_info.get('protein'))
    carbs = safe_float(meal_info.get('carbs'))
    fat = safe_float(meal_info.get('fat'))
    return {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
    }


def extract_macros(foodlog: Dict[str, Any]) -> Dict[str, float]:
    nutrition = foodlog.get('nutrition_data', {}) if isinstance(foodlog, dict) else {}
    return {
        'carbs': safe_float(nutrition.get('carbs') or nutrition.get('carbohydrates')),
        'protein': safe_float(nutrition.get('protein')),
        'fat': safe_float(nutrition.get('fat')),
        'fiber': safe_float(nutrition.get('fiber')),
        'sugar': safe_float(nutrition.get('sugar')),
    }


def extract_nutrients(foodlog: Dict[str, Any]) -> Dict[str, float]:
    nutrition = foodlog.get('nutrition_data', {}) if isinstance(foodlog, dict) else {}
    return {
        'energy': safe_float(nutrition.get('energy') or nutrition.get('calories')),
        'fat': safe_float(nutrition.get('fat')),
        'saturatedFat': safe_float(nutrition.get('saturated_fat')),
        'polyFat': safe_float(nutrition.get('poly_fat') or nutrition.get('polyunsaturated_fat')),
        'monoFat': safe_float(nutrition.get('mono_fat') or nutrition.get('monounsaturated_fat')),
        'cholestrol': safe_float(nutrition.get('cholestrol') or nutrition.get('cholesterol')),
        'fiber': safe_float(nutrition.get('fiber')),
        'sugar': safe_float(nutrition.get('sugar')),
        'sodium': safe_float(nutrition.get('sodium')),
        'potassium': safe_float(nutrition.get('potassium')),
    }


def aggregate_logs_by_date(logs: List[dict], start_date: date, end_date: date) -> Dict[str, List[dict]]:
    grouped = {d.strftime("%Y-%m-%d"): [] for d in daterange(start_date, end_date)}
    for log in logs:
        if not isinstance(log, dict):
            continue
        log_date = log.get('date')
        if not log_date or log_date not in grouped:
            continue
        entries = log.get('entries') or []
        if isinstance(entries, list):
            grouped[log_date].extend(entries)
    return grouped


def fetch_grouped_logs_for_user(user_id: str, start_date: date, end_date: date) -> Dict[str, List[dict]]:
    user_doc = user_activity_collection.find_one({"user_id": user_id})
    logs = []
    if isinstance(user_doc, dict):
        raw_logs = user_doc.get("logs")
        if isinstance(raw_logs, list):
            logs = raw_logs
    return aggregate_logs_by_date(logs, start_date, end_date)


def build_calories_series(grouped_logs: Dict[str, List[dict]]):
    labels = sorted(grouped_logs.keys())
    breakfast = []
    lunch = []
    dinner = []
    snacks = []
    for date_key in labels:
        entries = grouped_logs.get(date_key, [])
        day_meals = defaultdict(float)
        total_calories = 0.0
        for entry in entries:
            foodlog = entry.get('foodlog') if isinstance(entry, dict) else None
            if not isinstance(foodlog, dict):
                continue
            meal_info = foodlog.get('meal_info') if isinstance(foodlog, dict) else {}
            if not isinstance(meal_info, dict):
                meal_info = {}
            meal_type = str((meal_info.get('meal') or meal_info.get('meal_type') or '')).lower()
            values = extract_meal_calories(foodlog)
            total_calories += values['calories']
            if 'breakfast' in meal_type:
                day_meals['breakfast'] += values['calories']
            elif 'lunch' in meal_type:
                day_meals['lunch'] += values['calories']
            elif 'dinner' in meal_type:
                day_meals['dinner'] += values['calories']
            else:
                day_meals['snacks'] += values['calories']
        breakfast.append(round(day_meals['breakfast'], 2))
        lunch.append(round(day_meals['lunch'], 2))
        dinner.append(round(day_meals['dinner'], 2))
        snacks.append(round(day_meals['snacks'], 2))

    total = sum(sum(series) for series in (breakfast, lunch, dinner, snacks))
    avg = total / len(labels) if labels else 0

    summary = {
        'total': round(total, 2),
        'average': round(avg, 2),
        'goal': 2000.0,
    }

    return {
        'summary': summary,
        'labels': labels,
        'series': {
            'breakfast': breakfast,
            'lunch': lunch,
            'dinner': dinner,
            'snacks': snacks,
        },
        'entries': [
            {
                'label': label,
                'value': round(sum(values), 2),
            }
            for label, values in zip(labels, zip(breakfast, lunch, dinner, snacks))
        ],
    }


def build_macros_series(grouped_logs: Dict[str, List[dict]]):
    labels = sorted(grouped_logs.keys())
    carbs_series = []
    protein_series = []
    fat_series = []
    entries = []

    total_macros = defaultdict(float)

    for date_key in labels:
        entries_list = grouped_logs.get(date_key, [])
        day_macros = defaultdict(float)
        for entry in entries_list:
            foodlog = entry.get('foodlog') if isinstance(entry, dict) else None
            if not isinstance(foodlog, dict):
                continue
            macros = extract_macros(foodlog)
            for key, value in macros.items():
                day_macros[key] += value
                total_macros[key] += value

        carbs_series.append(round(day_macros['carbs'], 2))
        protein_series.append(round(day_macros['protein'], 2))
        fat_series.append(round(day_macros['fat'], 2))
        entries.append({
            'label': date_key,
            'macros': {
                'carbs': round(day_macros['carbs'], 2),
                'protein': round(day_macros['protein'], 2),
                'fat': round(day_macros['fat'], 2),
            }
        })

    total = sum(total_macros.values())
    if total <= 0:
        total = 1
    summaries = [
        {'label': 'Carbs', 'amount': round(total_macros['carbs'], 2), 'percent': round(total_macros['carbs'] / total * 100, 2)},
        {'label': 'Protein', 'amount': round(total_macros['protein'], 2), 'percent': round(total_macros['protein'] / total * 100, 2)},
        {'label': 'Fat', 'amount': round(total_macros['fat'], 2), 'percent': round(total_macros['fat'] / total * 100, 2)},
    ]

    return {
        'labels': labels,
        'series': {
            'carbs': carbs_series,
            'protein': protein_series,
            'fat': fat_series,
        },
        'entries': entries,
        'summary': summaries,
    }


def build_nutrients_map(grouped_logs: Dict[str, List[dict]]):
    aggregate_totals = defaultdict(float)
    for entries in grouped_logs.values():
        for entry in entries:
            foodlog = entry.get('foodlog') if isinstance(entry, dict) else None
            if not isinstance(foodlog, dict):
                continue
            nutrients = extract_nutrients(foodlog)
            for key, value in nutrients.items():
                aggregate_totals[key] += value

    highlights = sorted(
        (
            {'label': key.capitalize(), 'amount': round(value, 2), 'percent': 0.0}
            for key, value in aggregate_totals.items()
        ),
        key=lambda item: item['amount'],
        reverse=True,
    )[:5]

    return {
        'highlights': highlights,
        'detail': {key: round(value, 2) for key, value in aggregate_totals.items()},
    }


def build_progress_analytics(calories_payload, macros_payload, nutrients_payload):
    summary = {
        'total_calories': calories_payload['summary']['total'],
        'avg_calories': calories_payload['summary']['average'],
        'macro_focus': sorted(
            (item for item in macros_payload['summary'] if isinstance(item, dict)),
            key=lambda x: x.get('percent', 0),
            reverse=True,
        )[:1],
        'top_nutrients': nutrients_payload['highlights'],
    }
    summary['macro_focus'] = summary['macro_focus'][0] if summary['macro_focus'] else {}
    return summary


def get_user_id_from_token(request):
    """Extract user_id from JWT token in the Authorization header.
    Supports both 'Bearer <token>' and raw '<token>' formats.
    Returns (user_id, error_response) → you can check error_response in views.
    """
    auth_header = request.META.get('HTTP_AUTHORIZATION', '').strip()

    if not auth_header:
        return None, Response(
            {"error": "Missing Authorization header"},
            status=status.HTTP_401_UNAUTHORIZED
        )

    # Case 1: "Bearer <token>"
    if auth_header.startswith('Bearer '):
        token = auth_header.split(' ', 1)[1].strip()
    else:
        # Case 2: raw token directly
        token = auth_header

    if not token:
        return None, Response(
            status=status.HTTP_401_UNAUTHORIZED
        )

    try:
        token_obj = AccessToken(token)  # validates & decodes
    except InvalidToken as e:
        return None, Response(
            {"error": "Invalid or expired token", "details": str(e)},
            status=status.HTTP_401_UNAUTHORIZED
        )
    except Exception as e:
        return None, Response(
            {"error": "Failed to decode token", "details": str(e)},
            status=status.HTTP_401_UNAUTHORIZED
        )

    # Safely extract claim and normalize to string
    uid_claim = token_obj.get('user_id', None)
    if uid_claim is None:
        return None, Response(
            {"error": "User ID not found in token"},
            status=status.HTTP_401_UNAUTHORIZED
        )

    user_id = str(uid_claim).strip()
    if not user_id:
        return None, Response(
            {"error": "User ID not found in token"},
            status=status.HTTP_401_UNAUTHORIZED
        )

    return user_id, None


# ---------------------------------------------------------------------------
# User identity handling (standardized)
# ---------------------------------------------------------------------------
# Our mobile app and data store use an application-level user identifier like
# "USR12345" embedded in the JWT as the user_id claim. This is NOT the numeric
# Django DB primary key. To keep a consistent pattern across endpoints:
#
# 1) Always extract the app user ID via get_user_id_from_token(request).
# 2) Map that app user ID to a Django CustomUser instance by storing it in
#    CustomUser.phone and using get_or_create. This keeps foreign keys working
#    for relational models (e.g., WorkoutCompletion.user) while preserving the
#    app's identity model.
# 3) Avoid DRF's default authentication when using app-level IDs by setting
#    authentication_classes = [] and permission_classes = [] on such views.
#    Rely on get_user_id_from_token for auth and return its error responses.
#
# Reusable helpers below implement this pattern.

def map_app_user_id_to_django_user(user_id: str) -> CustomUser:
    """Return a Django CustomUser corresponding to the app-level user_id.

    We store the app user_id (e.g., "USR12345") in CustomUser.phone.
    """
    normalized = str(user_id).strip()
    user, _created = CustomUser.objects.get_or_create(phone=normalized)
    return user


def resolve_authenticated_user(request) -> Tuple[Optional[CustomUser], Optional[Response]]:
    """Resolve a Django user from the JWT using the standardized pattern.

    Returns (user, error_response). If error_response is not None, return it
    directly from the view.
    """
    user_id, error_response = get_user_id_from_token(request)
    if error_response:
        return None, error_response
    return map_app_user_id_to_django_user(user_id), None


def _build_manual_log_results(user_id: str, query: str) -> List[Dict[str, Any]]:
    history_results = _search_user_food_entries(user_id, query, limit=6)
    database_results = _search_food_database(query, limit=10)
    sample_results = _search_sample_foods(query, limit=6)

    combined: List[Dict[str, Any]] = []
    seen_payloads: set = set()
    seen_labels: set = set()

    def _append_unique(entries: List[Dict[str, Any]]):
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            foodlog = entry.get('foodlog') or {}
            try:
                fingerprint = json.dumps(foodlog, sort_keys=True, default=str)
            except Exception:
                fingerprint = str(foodlog)
            name = str(entry.get('name') or 'Food item')
            description = str(entry.get('description') or '')
            label_key = (name.strip().lower(), description.strip().lower())
            if fingerprint and fingerprint in seen_payloads:
                continue
            if label_key in seen_labels:
                continue
            if fingerprint:
                seen_payloads.add(fingerprint)
            seen_labels.add(label_key)
            combined.append({
                'name': name,
                'description': description,
                'foodlog': foodlog,
                'source': entry.get('source', 'sample'),
            })

    _append_unique(history_results)
    _append_unique(database_results)
    _append_unique(sample_results)

    if not combined:
        fallback = _search_sample_foods('', limit=5)
        _append_unique(fallback)

    return combined


def _build_manual_text_prediction(query: str) -> Dict[str, Any]:
    text_foodlog = generate_nutrition_from_text(query)
    if not isinstance(text_foodlog, dict):
        raise RuntimeError("Prediction service returned invalid data")

    text_foodlog.setdefault('source', 'text_query')
    entry = {
        'name': str(text_foodlog.get('food_name') or query or 'Food item'),
        'description': _build_food_description(text_foodlog),
        'foodlog': text_foodlog,
        'source': 'text_query',
    }
    return entry


class ManualLogSearchAPIView(APIView):
    """Return manual search suggestions sourced from user history and samples."""
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = ManualSearchSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        query = serializer.validated_data.get('query', '').strip()

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        combined = _build_manual_log_results(user_id, query)

        response_payload = {
            'status': True,
            'message': 'Manual capture completed',
            'result': combined,
        }

        try:
            safe_payload = _make_json_safe(response_payload)
            print(
                '[ManualLogSearch][RESPONSE]',
                json.dumps(safe_payload, ensure_ascii=False),
                flush=True,
            )
        except Exception as exc:
            print('[ManualLogSearch][RESPONSE][ERR]', str(exc), flush=True)

        return Response(response_payload, status=status.HTTP_200_OK)


def _validate_scan_payload(data: Dict[str, Any]) -> Tuple[Optional[Dict[str, Any]], Optional[Response]]:
    if not isinstance(data, dict):
        return None, Response({"error": "Invalid payload"}, status=status.HTTP_400_BAD_REQUEST)

    required_numeric_fields = ["height_cm"]
    for field in required_numeric_fields:
        value = safe_float(data.get(field))
        if value <= 0:
            return None, Response({"error": f"Missing or invalid {field}"}, status=status.HTTP_400_BAD_REQUEST)

    ratios = data.get("ratios") if isinstance(data.get("ratios"), dict) else {}
    estimates = data.get("estimates") if isinstance(data.get("estimates"), dict) else {}

    if not ratios:
        return None, Response({"error": "ratios object is required"}, status=status.HTTP_400_BAD_REQUEST)

    if not estimates:
        return None, Response({"error": "estimates object is required"}, status=status.HTTP_400_BAD_REQUEST)

    sanitized_landmarks: List[Dict[str, Any]] = []
    landmarks = data.get("landmarks")
    if landmarks:
        if not isinstance(landmarks, list):
            return None, Response({"error": "landmarks must be an array"}, status=status.HTTP_400_BAD_REQUEST)
        for item in landmarks:
            if not isinstance(item, dict):
                continue
            name = str(item.get("name")) if item.get("name") else None
            x = item.get("x")
            y = item.get("y")
            z = item.get("z")
            visibility = item.get("visibility")
            if name is None:
                continue
            sanitized_landmarks.append({
                "name": name,
                "x": safe_float(x),
                "y": safe_float(y),
                "z": safe_float(z),
                "visibility": safe_float(visibility),
            })

    metadata = data.get("metadata") if isinstance(data.get("metadata"), dict) else {}
    consent_flags = metadata.get("consent")
    if sanitized_landmarks and consent_flags not in ("granted", True):
        return None, Response({"error": "Explicit consent required when sending landmarks"}, status=status.HTTP_400_BAD_REQUEST)

    payload = {
        "height_cm": safe_float(data.get("height_cm")),
        "weight_kg": safe_float(data.get("weight_kg")),
        "ratios": {key: safe_float(val) for key, val in ratios.items() if isinstance(key, str)},
        "estimates": {key: safe_float(val) for key, val in estimates.items() if isinstance(key, str)},
        "landmarks": sanitized_landmarks,
        "metadata": metadata,
        "silhouette": data.get("silhouette") if isinstance(data.get("silhouette"), dict) else {},
        "source": str(data.get("source") or "app"),
    }
    return payload, None


def _queue_scan_insight(scan_doc: Dict[str, Any]) -> None:
    try:
        scan_id = scan_doc.get("_id")
        document = {
            "scan_id": scan_id,
            "user_id": scan_doc.get("user_id"),
            "status": "pending",
            "llm_model": "gemini-2.5-flash",
            "prompt_version": "v1",
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        db["scan_insights"].insert_one(document)
    except Exception as exc:
        print('[BodyScan][INSIGHT_QUEUE][ERR]', str(exc), flush=True)


class BodyScanAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        payload, validation_error = _validate_scan_payload(request.data)
        if validation_error:
            print('[BodyScan][VALIDATION][ERR]', validation_error.data, flush=True)
            return validation_error

        now_utc = datetime.utcnow()
        scan_document = {
            "user_id": user_id,
            "scan_at": payload.get("metadata", {}).get("timestamp") or now_utc,
            "height_cm": payload["height_cm"],
            "weight_kg": payload.get("weight_kg"),
            "ratios": payload["ratios"],
            "estimates": payload["estimates"],
            "landmarks": payload["landmarks"],
            "silhouette": payload["silhouette"],
            "metadata": payload["metadata"],
            "source": payload["source"],
            "status": "accepted",
            "created_at": now_utc,
            "updated_at": now_utc,
        }

        try:
            result = db["body_scans"].insert_one(scan_document)
            scan_document["_id"] = result.inserted_id
        except Exception as exc:
            print('[BodyScan][DB][ERR]', str(exc), flush=True)
            return Response({"error": "Failed to store scan"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        try:
            last_scan = db["body_scans"].find({"user_id": user_id}).sort("scan_at", -1).limit(2)
            scans = list(last_scan)
            trend_summary = {}
            if len(scans) >= 2:
                latest = scans[0]
                previous = scans[1]
                waist_latest = safe_float(latest.get("estimates", {}).get("waist_cm"))
                waist_prev = safe_float(previous.get("estimates", {}).get("waist_cm"))
                trend_summary = {
                    "last_scan": {
                        "date": str(previous.get("scan_at")),
                        "waist_cm": waist_prev,
                    },
                    "change": {
                        "waist_cm": round(waist_latest - waist_prev, 2),
                    },
                }
            else:
                trend_summary = {"change": {}, "last_scan": None}
        except Exception as exc:
            print('[BodyScan][TREND][ERR]', str(exc), flush=True)
            trend_summary = {"change": {}, "last_scan": None}

        _queue_scan_insight(scan_document)

        response_payload = {
            "scan_id": str(scan_document.get("_id")),
            "metrics": payload["estimates"],
            "trend_summary": trend_summary,
            "predictions": {},
            "insights": None,
        }

        return Response(response_payload, status=status.HTTP_201_CREATED)


INSIGHT_PROMPT_TEMPLATE = """
You are a friendly, clinically cautious fitness coach. Provide concise progress feedback without medical claims.
(1) Summarize notable measurement changes.
(2) Suggest one actionable tip (diet or activity) tailored to the data.
(3) Provide confidence as low/medium/high.
Return only JSON with keys summary, reason, action, confidence.
"""


def _build_insight_prompt(scan_doc: Dict[str, Any], previous_scan: Optional[Dict[str, Any]], nutrition: Optional[Dict[str, Any]], activity: Optional[Dict[str, Any]]) -> str:
    payload = {
        "user": {
            "id": scan_doc.get("user_id"),
        },
        "latest_scan": {
            "date": str(scan_doc.get("scan_at")),
            "weight_kg": safe_float(scan_doc.get("weight_kg")),
            "waist_cm": safe_float(scan_doc.get("estimates", {}).get("waist_cm")),
            "hip_cm": safe_float(scan_doc.get("estimates", {}).get("hip_cm")),
            "waist_hip_ratio": safe_float(scan_doc.get("ratios", {}).get("waist_hip")),
        },
        "previous_scan": None,
        "nutrition": nutrition or {},
        "activity": activity or {},
    }
    if previous_scan:
        payload["previous_scan"] = {
            "date": str(previous_scan.get("scan_at")),
            "waist_cm": safe_float(previous_scan.get("estimates", {}).get("waist_cm")),
            "weight_kg": safe_float(previous_scan.get("weight_kg")),
        }

    prompt = {
        "system": INSIGHT_PROMPT_TEMPLATE.strip(),
        "data": payload,
    }
    return json.dumps(prompt)


def _generate_scan_insight(scan_doc: Dict[str, Any]) -> Dict[str, Any]:
    user_id = scan_doc.get("user_id")
    previous_scan = db["body_scans"].find({"user_id": user_id, "_id": {"$ne": scan_doc.get("_id")}}).sort("scan_at", -1).limit(1)
    previous = next(previous_scan, None)

    nutrition = {}
    activity = {}

    user_doc = user_activity_collection.find_one({"user_id": user_id}) or {}
    if isinstance(user_doc, dict):
        nutrition = user_doc.get("nutrition_summary") if isinstance(user_doc.get("nutrition_summary"), dict) else {}
        activity = user_doc.get("activity_summary") if isinstance(user_doc.get("activity_summary"), dict) else {}

    prompt_text = _build_insight_prompt(scan_doc, previous, nutrition, activity)

    response = genai_client.models.generate_content(
        model="gemini-2.5-flash",
        contents=[prompt_text],
    )

    insight_payload: Dict[str, Any] = {
        "summary": None,
        "reason": None,
        "action": None,
        "confidence": None,
    }

    if hasattr(response, 'candidates') and response.candidates:
        text_response = response.candidates[0].content.parts[0].text if response.candidates[0].content.parts else None
    else:
        text_response = str(response)

    if not text_response:
        raise RuntimeError("Gemini returned empty response")

    try:
        parsed = json.loads(text_response)
        if isinstance(parsed, dict):
            insight_payload.update({k: parsed.get(k) for k in insight_payload})
    except json.JSONDecodeError:
        parsed = text_response

    return insight_payload


class BodyScanInsightAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        scan_id = request.data.get("scan_id")
        if not scan_id:
            return Response({"error": "scan_id is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            from bson import ObjectId
            scan_object_id = ObjectId(scan_id)
        except Exception:
            return Response({"error": "Invalid scan_id"}, status=status.HTTP_400_BAD_REQUEST)

        scan_doc = db["body_scans"].find_one({"_id": scan_object_id, "user_id": user_id})
        if not scan_doc:
            return Response({"error": "Scan not found"}, status=status.HTTP_404_NOT_FOUND)

        insight_doc = db["scan_insights"].find_one({"scan_id": scan_doc.get("_id")})
        if insight_doc and insight_doc.get("status") == "completed":
            return Response({
                "scan_id": scan_id,
                "insight": {
                    "summary": insight_doc.get("summary"),
                    "reason": insight_doc.get("reason"),
                    "action": insight_doc.get("action"),
                    "confidence": insight_doc.get("confidence"),
                }
            }, status=status.HTTP_200_OK)

        try:
            insight_payload = _generate_scan_insight(scan_doc)
            db["scan_insights"].update_one(
                {"scan_id": scan_doc.get("_id")},
                {"$set": {
                    "summary": insight_payload.get("summary"),
                    "reason": insight_payload.get("reason"),
                    "action": insight_payload.get("action"),
                    "confidence": insight_payload.get("confidence"),
                    "status": "completed",
                    "updated_at": datetime.utcnow(),
                }},
                upsert=True,
            )
        except Exception as exc:
            print('[BodyScanInsight][ERR]', str(exc), flush=True)
            db["scan_insights"].update_one(
                {"scan_id": scan_doc.get("_id")},
                {"$set": {
                    "status": "error",
                    "error_detail": str(exc),
                    "updated_at": datetime.utcnow(),
                }},
                upsert=True,
            )
            return Response({"error": "Failed to generate insight"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        refreshed = db["scan_insights"].find_one({"scan_id": scan_doc.get("_id")})
        return Response({
            "scan_id": scan_id,
            "insight": {
                "summary": refreshed.get("summary"),
                "reason": refreshed.get("reason"),
                "action": refreshed.get("action"),
                "confidence": refreshed.get("confidence"),
            }
        }, status=status.HTTP_200_OK)


class ManualLogPredictAPIView(APIView):
    """Return AI-assisted nutrition prediction for a manual query."""
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = ManualSearchSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        query = serializer.validated_data.get('query', '').strip()

        if not query:
            return Response({
                'status': False,
                'message': 'Food description is required',
            }, status=status.HTTP_400_BAD_REQUEST)

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        try:
            prediction_entry = _build_manual_text_prediction(query)
        except Exception as exc:
            print('[ManualLogPredict][ERR]', str(exc), flush=True)
            return Response({
                'status': False,
                'message': 'Failed to generate prediction',
                'details': str(exc),
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        response_payload = {
            'status': True,
            'message': 'Manual prediction completed',
            'result': [prediction_entry],
        }

        try:
            safe_payload = _make_json_safe(response_payload)
            print(
                '[ManualLogPredict][RESPONSE]',
                json.dumps(safe_payload, ensure_ascii=False),
                flush=True,
            )
        except Exception as exc:
            print('[ManualLogPredict][RESPONSE][ERR]', str(exc), flush=True)

        return Response(response_payload, status=status.HTTP_200_OK)


class ManualLogSearchTestAPIView(APIView):
    """Convenience endpoint to test manual log search flow with a hardcoded query."""
    authentication_classes = []
    permission_classes = []

    TEST_QUERY = "grilled chicken sandwich with fries"
    DEFAULT_USER_ID = os.getenv("MANUAL_LOG_TEST_USER_ID", "manual-log-test-user")

    def get(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION', '').strip()
        if auth_header:
            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                return error_response
        else:
            user_id = self.DEFAULT_USER_ID

        combined = _build_manual_log_results(user_id, self.TEST_QUERY)

        return Response({
            'status': True,
            'message': 'Manual capture test completed',
            'query': self.TEST_QUERY,
            'result': combined,
        }, status=status.HTTP_200_OK)


def _normalize_diet_plan_document(entry: Dict[str, Any]) -> Dict[str, Any]:
    entry = entry or {}
    macros = entry.get("macros") if isinstance(entry.get("macros"), dict) else {}
    normalized = {
        "id": entry.get("id") or entry.get("_id") or uuid.uuid4().hex,
        "name": entry.get("name", "Diet Plan"),
        "goal": entry.get("goal", ""),
        "description": entry.get("description", ""),
        "macros": {
            "protein": int(safe_float(macros.get("protein") or entry.get("protein")) or 0),
            "carbs": int(safe_float(macros.get("carbs") or entry.get("carbs")) or 0),
            "fat": int(safe_float(macros.get("fat") or entry.get("fat")) or 0),
        },
    }

    # Optional numeric extras
    fiber = entry.get("fiber")
    if fiber is not None:
        try:
            normalized["fiber"] = int(fiber)
        except (TypeError, ValueError):
            pass

    water = entry.get("water_liters") or entry.get("water")
    if water is not None:
        try:
            normalized["water_liters"] = float(water)
        except (TypeError, ValueError):
            pass

    if entry.get("intake_text"):
        normalized["intake_text"] = entry.get("intake_text")

    image_value = entry.get("image") or entry.get("image_path") or entry.get("imageUrl")
    if image_value:
        normalized["image"] = image_value

    # Optional metadata
    if entry.get("calories") is not None:
        try:
            normalized["calories"] = int(entry.get("calories"))
        except (TypeError, ValueError):
            pass
    if entry.get("saved_at"):
        normalized["saved_at"] = entry.get("saved_at")

    return normalized


class DietPlanListCreateAPIView(APIView):
    """Create and list saved diet plans for the authenticated user."""
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = DietPlanSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        payload = serializer.validated_data
        diet_id = payload.get("id") or uuid.uuid4().hex
        diet_entry = {
            "id": diet_id,
            "name": payload.get("name"),
            "goal": payload.get("goal", ""),
            "description": payload.get("description", ""),
            "macros": payload.get("macros"),
            "fiber": payload.get("fiber"),
            "water_liters": payload.get("water_liters"),
            "intake_text": payload.get("intake_text"),
            "image": payload.get("image"),
            "calories": payload.get("calories"),
            "saved_at": datetime.utcnow().isoformat(),
        }

        user_doc = user_info_collection.find_one({"signup.user_id": user_id})
        if not user_doc:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        diet_plans = user_doc.get("diet_plans") or []
        if not isinstance(diet_plans, list):
            diet_plans = []

        updated = False
        for index, existing in enumerate(diet_plans):
            if not isinstance(existing, dict):
                continue
            if existing.get("id") == diet_id or (
                existing.get("name") == diet_entry.get("name") and
                existing.get("description") == diet_entry.get("description")
            ):
                merged = dict(existing)
                merged.update({k: v for k, v in diet_entry.items() if v is not None})
                diet_plans[index] = merged
                updated = True
                break

        if not updated:
            diet_plans.append(diet_entry)

        user_info_collection.update_one(
            {"signup.user_id": user_id},
            {"$set": {"diet_plans": diet_plans}}
        )

        normalized = _normalize_diet_plan_document(diet_entry)
        return Response(
            {
                "status": True,
                "message": "Diet added to your plans",
                "diet": normalized,
            },
            status=status.HTTP_201_CREATED,
        )

    def get(self, request):
        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        user_doc = user_info_collection.find_one({"signup.user_id": user_id})
        if not user_doc:
            return Response({
                "status": False,
                "message": "User not found",
                "diets": [],
            }, status=status.HTTP_404_NOT_FOUND)

        diet_plans = user_doc.get("diet_plans")
        if not isinstance(diet_plans, list):
            diet_plans = []

        normalized_plans = [_normalize_diet_plan_document(plan) for plan in diet_plans if isinstance(plan, dict)]

        return Response(
            {
                "status": True,
                "message": "Diets fetched successfully",
                "diets": normalized_plans,
            },
            status=status.HTTP_200_OK,
        )


class WorkoutListAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        workouts = Workout.objects.all()
        serializer = WorkoutSerializer(workouts, many=True)
        # Debug: log count and preview of items
        try:
            data = serializer.data
            count = len(data) if isinstance(data, list) else 0
            preview = []
            if isinstance(data, list):
                for item in data[:5]:
                    try:
                        preview.append({
                            'slug': item.get('slug'),
                            'name': item.get('name'),
                        })
                    except Exception:
                        preview.append(str(item)[:120])
            print(f"[WorkoutListAPIView][RES] count={count} preview={preview}", flush=True)
        except Exception as exc:
            print(f"[WorkoutListAPIView][ERR] Failed to build debug preview: {exc}", flush=True)
        return Response(
            {
                "status": True,
                "message": "Workouts fetched successfully",
                "workouts": serializer.data,
            },
            status=status.HTTP_200_OK,
        )


class WorkoutDetailAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, slug):
        try:
            workout = Workout.objects.get(slug=slug)
        except Workout.DoesNotExist:
            return Response(
                {
                    "status": False,
                    "message": "Workout not found",
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = WorkoutSerializer(workout)
        return Response(
            {
                "status": True,
                "message": "Workout fetched successfully",
                "workout": serializer.data,
            },
            status=status.HTTP_200_OK,
        )


class WorkoutCompleteAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request, slug):
        # Resolve user using the standardized helpers
        user, error_response = resolve_authenticated_user(request)
        if error_response:
            return error_response
        try:
            workout = Workout.objects.get(slug=slug)
        except Workout.DoesNotExist:
            return Response({"status": False, "message": "Workout not found"}, status=status.HTTP_404_NOT_FOUND)

        payload = request.data if isinstance(request.data, dict) else {}

        def _float_or_default(value, default: float = 0.0) -> float:
            try:
                if value in (None, ""):
                    return default
                return float(value)
            except (TypeError, ValueError):
                return default

        calories = _float_or_default(payload.get("calories"), float(workout.calories_average))

        completion = WorkoutCompletion.objects.create(
            user=user,
            workout=workout,
            calories_kcal=calories,
        )

        data = WorkoutCompletionSerializer(completion).data
        return Response(
            {
                "status": True,
                "message": "Workout marked as complete",
                "completion": data,
            },
            status=status.HTTP_201_CREATED,
        )


class WorkoutSummaryAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        # Resolve user using the standardized helpers
        user, error_response = resolve_authenticated_user(request)
        if error_response:
            return error_response
        try:
            days = int(request.query_params.get("days", 7))
        except (TypeError, ValueError):
            days = 7
        days = max(1, min(days, 90))

        now_ts = now()
        window_start = now_ts - timedelta(days=days - 1)

        completions = (
            WorkoutCompletion.objects
            .filter(user=user, completed_at__gte=window_start)
            .select_related("workout")
            .order_by("-completed_at")
        )

        # Aggregate daily totals
        totals_by_day: Dict[str, float] = {}
        for comp in completions:
            day_key = comp.completed_at.astimezone(now_ts.tzinfo).date().isoformat()
            totals_by_day.setdefault(day_key, 0.0)
            try:
                totals_by_day[day_key] += float(comp.calories_kcal)
            except (TypeError, ValueError):
                continue

        trend = []
        for delta in range(days):
            day = (window_start + timedelta(days=delta)).date()
            key = day.isoformat()
            trend.append({
                "date": key,
                "calories": round(totals_by_day.get(key, 0.0), 2),
            })

        total_last_window = sum(item["calories"] for item in trend)
        average = round(total_last_window / days, 2) if days else 0.0

        recent = completions[:10]
        recent_serialized = WorkoutCompletionSerializer(recent, many=True).data

        return Response(
            {
                "status": True,
                "message": "Workout summary fetched successfully",
                "summary": {
                    "days": days,
                    "total_calories": round(total_last_window, 2),
                    "average_calories": average,
                    "trend": trend,
                    "recent_completions": recent_serialized,
                },
            },
            status=status.HTTP_200_OK,
        )


def _fetch_user_weight_profile(user_doc: Dict[str, Any]) -> Dict[str, Any]:
    profile = {}
    if not isinstance(user_doc, dict):
        return profile
    profile = user_doc.get("user_profile") if isinstance(user_doc.get("user_profile"), dict) else {}
    return profile or {}


def _build_weight_trend(entries: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    trend_points = []
    for entry in entries:
        weight = safe_float(entry.get("weight") or entry.get("weight_kg"))
        if weight <= 0:
            continue
        date_val = entry.get("date")
        if isinstance(date_val, datetime):
            date_str = date_val.strftime("%Y-%m-%d")
        else:
            date_str = str(date_val)
        trend_points.append({
            "date": date_str,
            "weight": round(weight, 2),
        })
    trend_points.sort(key=lambda item: item.get("date", ""))
    return trend_points


def _build_weight_entries(entries: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    normalized = []
    for entry in entries:
        weight = safe_float(entry.get("weight") or entry.get("weight_kg"))
        if weight <= 0:
            continue
        date_val = entry.get("date")
        if isinstance(date_val, datetime):
            date_str = date_val.strftime("%Y-%m-%d")
        else:
            date_str = str(date_val)
        normalized.append({
            "date": date_str,
            "weight": round(weight, 2),
            "calories": int(safe_float(entry.get("calories") or entry.get("intake"))),
            "burnt": int(safe_float(entry.get("burnt") or entry.get("calories_burned"))),
        })
    normalized.sort(key=lambda item: item.get("date", ""), reverse=True)
    return normalized


def _compute_bmi(weight_kg: float, height_cm: float) -> Dict[str, Any]:
    if weight_kg <= 0 or height_cm <= 0:
        return {
            "score": 0.0,
            "status": "Unknown",
            "range": "18.5 - 24.9",
        }
    height_m = height_cm / 100
    bmi = weight_kg / (height_m ** 2)
    if bmi < 18.5:
        status = "Underweight"
    elif bmi < 25:
        status = "Normal"
    elif bmi < 30:
        status = "Overweight"
    else:
        status = "Obese"
    return {
        "score": round(bmi, 1),
        "status": status,
        "range": "18.5 - 24.9",
    }


def _estimate_projected_goal_date(current_weight: float, goal_weight: float, entries: List[Dict[str, Any]]) -> Optional[str]:
    if current_weight <= 0 or goal_weight <= 0:
        return None
    if not entries:
        return None

    try:
        weights = []
        dates = []
        for entry in entries:
            weight = safe_float(entry.get("weight"))
            date_str = entry.get("date")
            if weight <= 0 or not date_str:
                continue
            weights.append(weight)
            dates.append(datetime.strptime(date_str, "%Y-%m-%d"))
        if len(weights) < 2:
            return None
        earliest = dates[-1]
        latest = dates[0]
        delta_days = (earliest - latest).days or 1
        delta_weight = weights[-1] - weights[0]
        daily_change = delta_weight / delta_days
        if daily_change == 0:
            return None
        remaining = goal_weight - current_weight
        estimated_days = int(abs(remaining / daily_change))
        projected_date = (datetime.utcnow() + timedelta(days=estimated_days)).date()
        return projected_date.isoformat()
    except Exception:
        return None


class WeightDashboardAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        user_doc = user_info_collection.find_one({"signup.user_id": user_id}) or {}
        weight_doc = user_activity_collection.find_one({"user_id": user_id, "type": "weight_log"}) or {}

        profile = _fetch_user_weight_profile(user_doc)
        goal_weight = safe_float(profile.get("goal_weight") or profile.get("target_weight"))
        current_weight = safe_float(profile.get("weight") or profile.get("current_weight"))
        height_cm = safe_float(profile.get("height")) or 0.0

        raw_entries = weight_doc.get("entries") if isinstance(weight_doc.get("entries"), list) else []
        trend = _build_weight_trend(raw_entries)
        entries = _build_weight_entries(raw_entries)

        if entries:
            current_weight = entries[0]["weight"]
        elif weight_doc.get("current_weight"):
            current_weight = safe_float(weight_doc.get("current_weight"))

        progress_percent = 0.0
        if goal_weight > 0 and current_weight > 0:
            start_weight = safe_float(weight_doc.get("start_weight") or profile.get("weight"))
            if start_weight > 0:
                journey = abs(start_weight - goal_weight)
                remaining = abs(current_weight - goal_weight)
                if journey > 0:
                    progress_percent = max(0.0, min(100.0, (journey - remaining) / journey * 100))

        projected_goal_date = _estimate_projected_goal_date(current_weight, goal_weight, entries)
        bmi = _compute_bmi(current_weight, height_cm)

        response_payload = {
            "goal_weight": round(goal_weight, 2),
            "current_weight": round(current_weight, 2),
            "progress_percent": round(progress_percent, 2),
            "projected_goal_date": projected_goal_date,
            "trend": trend,
            "entries": entries,
            "bmi": bmi,
        }

        return Response(response_payload, status=status.HTTP_200_OK)


class ManualLogSaveAPIView(APIView):
    """Persist a manually entered food log for the authenticated user."""
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = ManualSaveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        query = serializer.validated_data.get('query', '').strip()
        selection = serializer.validated_data.get('selection')

        if not query and not selection:
            return Response({
                'status': False,
                'message': 'Provide a query or select a food item to save.',
            }, status=status.HTTP_400_BAD_REQUEST)

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        food_payload = _foodlog_from_selection(selection, query)
        food_payload.setdefault('source', 'manual')

        entry_date = timezone.localdate().isoformat()

        _append_foodlog_entry(
            user_id=user_id,
            food_payload=food_payload,
            date_str=entry_date,
            metadata={
                'source': 'manual_entry',
                'query': query,
                'saved_at': timezone.now().isoformat(),
            }
        )

        return Response({
            'status': True,
            'message': 'Manual entry saved successfully',
            'entry': food_payload,
        }, status=status.HTTP_201_CREATED)


class ManualLogCaptureAPIView(APIView):
    """Capture a manual selection without immediately saving to calendar."""
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = ManualCaptureSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        query = serializer.validated_data.get('query', '').strip()
        selection = serializer.validated_data.get('selection')

        if not query and not selection:
            return Response({
                'status': False,
                'message': 'Select a food item or provide details to capture.',
            }, status=status.HTTP_400_BAD_REQUEST)

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        food_payload = _foodlog_from_selection(selection, query)
        food_payload.setdefault('source', 'manual_capture')

        _append_foodlog_entry(
            user_id=user_id,
            food_payload=food_payload,
            metadata={
                'source': 'manual_capture',
                'query': query,
                'saved_at': datetime.utcnow().isoformat(),
            }
        )

        return Response({
            'status': True,
            'message': 'Manual capture stored successfully',
            'capture': food_payload,
        }, status=status.HTTP_201_CREATED)


class FoodLogSearchAPIView(APIView):
    """Provide food log entries for the Logs screen with optional search and limits."""
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        serializer = LogsSearchSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        query = serializer.validated_data.get('query', '') or ''
        limit = serializer.validated_data.get('limit') or 25
        requested_date = request.query_params.get('date') or now().strftime("%Y-%m-%d")

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        query_lower = query.strip().lower()
        collected = _collect_user_foodlogs(user_id)
        results: List[Dict[str, Any]] = []

        for date_str, foodlog in collected:
            if date_str != requested_date:
                continue
            entry = _build_foodlog_entry(foodlog, date_str=date_str)
            haystack = ' '.join(
                filter(None, [
                    entry.get('name'),
                    entry.get('description'),
                    entry.get('meal'),
                    entry.get('source'),
                ])
            ).lower()
            if query_lower and query_lower not in haystack:
                continue
            results.append(entry)
            if len(results) >= limit:
                break

        used_samples = False
        if not results:
            used_samples = True
            sample_payloads = _search_sample_foods(query, limit=limit)
            for sample in sample_payloads:
                foodlog = sample.get('foodlog') or {}
                entry = _build_foodlog_entry(
                    foodlog,
                    date_str=requested_date,
                    source=sample.get('source', 'sample'),
                )
                entry['name'] = sample.get('name', entry['name'])
                entry['description'] = sample.get('description', entry['description'])
                if not entry.get('captured_display'):
                    entry['captured_display'] = '08:30 AM'
                results.append(entry)
                if len(results) >= limit:
                    break
        print('manual log results..',results)
        return Response({
            'status': True,
            'date': requested_date,
            'count': len(results),
            'used_samples': used_samples,
            'results': results,
        }, status=status.HTTP_200_OK)


def store_image_and_response_to_mongo(image_bytes, response_text, user_id=None):
    """Store image and response in MongoDB.
    user_id is optional to support unauthenticated calls (e.g. basic multi-food detection).
    """
    document = {
# {{ ... }}
        'image': Binary(image_bytes),
        'response': response_text,
        'user_id': user_id,
        'created_at': datetime.utcnow()
    }
    result = img_store_collection.insert_one(document)
    return str(result.inserted_id)

def store_analysis_result(user_id, analysis_data, image_id):
    """Store analysis result in user_activity collection."""
    document = {
        'user_id': user_id,
        'type': 'food_analysis',
        'data': analysis_data,
        'image_id': image_id,
        'created_at': datetime.utcnow()
    }
    result = user_activity_collection.insert_one(document)
    return str(result.inserted_id)

class LogFoodAPIView(APIView):
    """API to log food intake for a user."""
    # Bypass DRF auth/permissions; we manually validate JWT inside
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        # Confirm request reached this view early
        print('[LogFood][HIT]', {'method': getattr(request, 'method', None), 'path': getattr(request, 'path', None)}, flush=True)
        # Optional dryrun to test routing quickly
        try:
            if request.GET.get('dryrun') == '1':
                print('[LogFood][DRYRUN]', flush=True)
                return Response({"status": "ok"}, status=status.HTTP_200_OK)
        except Exception:
            pass
        try:
            user_id, error_response  = get_user_id_from_token(request)
            if error_response:
                return error_response

            payload = request.data or {}
            if isinstance(payload, dict) and 'data' in payload and isinstance(payload.get('data'), dict):
                nutrition_data = payload['data']
            else:
                nutrition_data = payload

            if not isinstance(nutrition_data, dict) or not nutrition_data:
                print('[LogFood][REQ][ERR]', {'user_id': user_id, 'payload_type': type(payload).__name__}, flush=True)
                return Response({"error": "Missing or invalid nutrition data"}, status=status.HTTP_400_BAD_REQUEST)

            print('[LogFood][REQ]', {
                'user_id': user_id,
                'keys': list(nutrition_data.keys()),
            }, flush=True)

            today = now().strftime("%Y-%m-%d")
            user_doc = user_activity_collection.find_one({"user_id": user_id})

            if user_doc:
                logs_list = user_doc.get("logs") or []
                if not isinstance(logs_list, list):
                    logs_list = []
                log_found = False
                for log in logs_list:
                    if isinstance(log, dict) and log.get("date") == today:
                        log.setdefault("entries", []).append({"foodlog": nutrition_data})
                        log_found = True
                        break

                if not log_found:
                    logs_list.append({
                        "date": today,
                        "entries": [{"foodlog": nutrition_data}]
                    })

                user_activity_collection.update_one({"user_id": user_id}, {"$set": {"logs": logs_list}})
            else:
                new_log = {
                    "user_id": user_id,
                    "logs": [
                        {
                            "date": today,
                            "entries": [{"foodlog": nutrition_data}]
                        }
                    ]
                }
                user_activity_collection.insert_one(new_log)

            print('[LogFood][RES]', {'status': 201, 'date': today}, flush=True)
            return Response({"message": "Log saved successfully"}, status=status.HTTP_201_CREATED)
        except Exception as e:
            print('[LogFood][ERR]', str(e), flush=True)
            print('[LogFood][TRACE]', traceback.format_exc(), flush=True)
            return Response({"error": "Failed to save log", "details": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class LogWaterAPIView(APIView):
    """API to log water intake for a user."""
    # Bypass DRF auth/permissions; we validate JWT manually inside
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        # Early print to confirm request reached this view
        print('[LogWater][HIT]', {'method': getattr(request, 'method', None), 'path': getattr(request, 'path', None)}, flush=True)
        try:
            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                print('[LogWater][AUTH][ERR]', getattr(error_response, 'data', None), flush=True)
                return error_response

            payload = request.data or {}
            # Expecting: { "amount_ml": number, "timestamp": optional ISO string, "date": optional YYYY-MM-DD }
            try:
                amount_ml = float(payload.get("amount_ml"))
            except (TypeError, ValueError):
                print('[LogWater][REQ][ERR]', {'user_id': user_id, 'payload': payload}, flush=True)
                return Response({"error": "amount_ml is required and must be a number"}, status=status.HTTP_400_BAD_REQUEST)

            timestamp = payload.get("timestamp") or datetime.utcnow().isoformat()
            date_str = payload.get("date") or now().strftime("%Y-%m-%d")
            print('[LogWater][REQ]', {'user_id': user_id, 'amount_ml': amount_ml, 'timestamp': timestamp, 'date': date_str}, flush=True)

            # Upsert into user_activity logs under the same structure used for food logs
            user_doc = user_activity_collection.find_one({"user_id": user_id})
            entry = {"waterlog": {"amount_ml": amount_ml, "timestamp": timestamp}}

            if user_doc:
                logs = user_doc.get("logs") or []
                if not isinstance(logs, list):
                    logs = []
                log_found = False
                for log in logs:
                    if isinstance(log, dict) and log.get("date") == date_str:
                        log.setdefault("entries", []).append(entry)
                        log_found = True
                        break
                if not log_found:
                    logs.append({
                        "date": date_str,
                        "entries": [entry]
                    })
                user_activity_collection.update_one({"user_id": user_id}, {"$set": {"logs": logs}})
            else:
                user_activity_collection.insert_one({
                    "user_id": user_id,
                    "logs": [
                        {"date": date_str, "entries": [entry]}
                    ]
                })

            print('[LogWater][RES]', {'status': 201, 'date': date_str}, flush=True)
            return Response({"message": "Water log saved successfully"}, status=status.HTTP_201_CREATED)
        except Exception as e:
            print('[LogWater][ERR]', str(e), flush=True)
            print('[LogWater][TRACE]', traceback.format_exc(), flush=True)
            return Response({"error": "Failed to save water log", "details": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class GetWaterLogAPIView(APIView):
    """API to fetch water logs summary for a specific date."""
    # Bypass DRF auth/permissions; we validate JWT manually
    authentication_classes = []
    permission_classes = []

    def get(self, request, date_str):
        print('[GetWaterLog][HIT]', {'method': getattr(request, 'method', None), 'path': getattr(request, 'path', None)}, flush=True)
        try:
            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                print('[GetWaterLog][AUTH][ERR]', getattr(error_response, 'data', None), flush=True)
                return error_response

            user_doc = user_activity_collection.find_one({"user_id": user_id})
            if not user_doc:
                print('[GetWaterLog][DB]', {'user_id': user_id, 'found': False}, flush=True)
                return Response({"error": "No logs found"}, status=status.HTTP_404_NOT_FOUND)

            entries_for_date = []
            total_ml = 0.0
            print('[GetWaterLog][REQ]', {'user_id': user_id, 'date': date_str}, flush=True)
            logs = user_doc.get("logs") or []
            if not isinstance(logs, list):
                logs = []
            for log in logs:
                if not isinstance(log, dict):
                    continue
                if log.get("date") == date_str:
                    for entry in log.get("entries", []) or []:
                        if not isinstance(entry, dict):
                            continue
                        wl = entry.get("waterlog")
                        if isinstance(wl, dict):
                            entries_for_date.append(wl)
                            try:
                                total_ml += float(wl.get("amount_ml", 0))
                            except (TypeError, ValueError):
                                pass

            print('[GetWaterLog][RES]', {'count': len(entries_for_date), 'total_ml': total_ml}, flush=True)
            return Response({
                "date": date_str,
                "entries": entries_for_date,
                "total_water_ml": total_ml
            }, status=status.HTTP_200_OK)
        except Exception as e:
            print('[GetWaterLog][ERR]', str(e), flush=True)
            print('[GetWaterLog][TRACE]', traceback.format_exc(), flush=True)
            return Response({"error": "Failed to fetch water logs", "details": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



class GetWaterHistoryAPIView(APIView):
    """API to fetch water intake history across a date range."""

    authentication_classes = []
    permission_classes = []
    _DEFAULT_DAYS = 7
    _MAX_DAYS = 30

    def get(self, request):
        print('[GetWaterHistory][HIT]', {
            'method': getattr(request, 'method', None),
            'path': getattr(request, 'path', None),
        }, flush=True)
        try:
            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                print('[GetWaterHistory][AUTH][ERR]', getattr(error_response, 'data', None), flush=True)
                return error_response

            query_params = getattr(request, 'query_params', request.GET)
            raw_days = query_params.get('days')
            try:
                requested_days = int(raw_days) if raw_days is not None else self._DEFAULT_DAYS
            except (TypeError, ValueError):
                requested_days = self._DEFAULT_DAYS
            requested_days = max(1, min(self._MAX_DAYS, requested_days))

            raw_end_date = query_params.get('end_date')
            if raw_end_date:
                try:
                    end_date = datetime.strptime(raw_end_date, "%Y-%m-%d").date()
                except ValueError:
                    return Response({"error": "Invalid end_date, expected YYYY-MM-DD"}, status=status.HTTP_400_BAD_REQUEST)
            else:
                end_date = now().date()
            start_date = end_date - timedelta(days=requested_days - 1)

            user_doc = user_activity_collection.find_one({"user_id": user_id}) or {}
            raw_logs = user_doc.get('logs') if isinstance(user_doc.get('logs'), list) else []

            entries_by_date: Dict[str, List[dict]] = {}
            for log in raw_logs:
                if not isinstance(log, dict):
                    continue
                date_key = log.get('date')
                if not isinstance(date_key, str):
                    continue
                entries = log.get('entries') if isinstance(log.get('entries'), list) else []
                if entries:
                    entries_by_date.setdefault(date_key, []).extend(entries)

            history: List[Dict[str, Any]] = []
            total_water_ml = 0.0

            for day in daterange(start_date, end_date):
                key = day.strftime("%Y-%m-%d")
                day_entries: List[dict] = []
                day_total = 0.0
                for entry in entries_by_date.get(key, []):
                    if not isinstance(entry, dict):
                        continue
                    wl = entry.get('waterlog')
                    if isinstance(wl, dict):
                        day_entries.append(wl)
                        try:
                            day_total += float(wl.get('amount_ml') or 0)
                        except (TypeError, ValueError):
                            pass
                total_water_ml += day_total
                history.append({
                    "date": key,
                    "total_water_ml": round(day_total, 2),
                    "entries": day_entries,
                })

            payload = {
                "start_date": start_date.strftime("%Y-%m-%d"),
                "end_date": end_date.strftime("%Y-%m-%d"),
                "days_requested": requested_days,
                "days": history,
                "total_water_ml": round(total_water_ml, 2),
            }
            print('[GetWaterHistory][RES]', {
                'start_date': payload['start_date'],
                'end_date': payload['end_date'],
                'days': len(history),
                'total': payload['total_water_ml'],
            }, flush=True)
            return Response(payload, status=status.HTTP_200_OK)
        except Exception as e:
            print('[GetWaterHistory][ERR]', str(e), flush=True)
            print('[GetWaterHistory][TRACE]', traceback.format_exc(), flush=True)
            return Response({"error": "Failed to fetch water history", "details": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



class GetFoodLogsAPIView(APIView):
    """API to get food logs for a user."""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            user_id = request.user.id
            date = request.query_params.get('date')  # YYYY-MM-DD format
            
            query = {'user_id': user_id, 'type': 'daily_food_log'}
            if date:
                query['date'] = date
            
            # Get logs, most recent first
            logs = list(user_activity_collection
                      .find(query)
                      .sort('date', -1))
            
            # Convert ObjectId to string for JSON serialization
            for log in logs:
                log['_id'] = str(log['_id'])
            
            return Response({
                'status': 'success',
                'count': len(logs),
                'data': logs
            })
            
        except Exception as e:
            return Response(
                {'error': 'Failed to fetch food logs', 'details': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

def store_food_log(user_id, food_data, image_id=None):
    try:
        # MongoDB credentials
        password = "Soumya"
        encoded_password = urllib.parse.quote_plus(password)
        connection_string=f"mongodb+srv://soumya-123:{encoded_password}@cluster0.zaytioc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
        # Connect to MongoDB
        client = MongoClient(connection_string)
        db = client["nutrition-app"]
        food_logs = db["food-logs"]
        
        # Create a food log document
        log_entry = {
            "user_id": user_id,
            "food_items": food_data.get("nutrition_data", []),
            "image_id": image_id,
            "log_date": datetime.utcnow(),
            "created_at": datetime.utcnow()
        }
        
        # Insert the log
        result = food_logs.insert_one(log_entry)
        return str(result.inserted_id)
        
    except Exception as e:
        raise RuntimeError(f"Failed to store food log: {str(e)}")


class OTPVerifyView(APIView):
    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        if serializer.is_valid():
            phone = serializer.validated_data['phone']
            otp = serializer.validated_data['otp']
            try:
                otp_record = OTP.objects.get(phone=phone, otp=otp)
                password = request.session.get('signup_password')
                user = CustomUser.objects.create_user(phone=phone, password=password)
                otp_record.delete()
                return Response({'message': 'Signup successful'})
            except OTP.DoesNotExist:
                return Response({'message': 'Invalid OTP'}, status=400)
        return Response(serializer.errors, status=400)



class MultiFoodDetectionAPIView(APIView):
    parser_classes = [MultiPartParser]  # To handle file upload

    def post(self, request):
        image_file = request.FILES.get('image')

        if not image_file:
            return Response({'error': 'Missing image file'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            image_bytes = image_file.read()

            prompt = (
                "List the different food items visible in this image. "
                "Return them as a comma-separated list only. No explanation."
            )

            response = genai_client.models.generate_content(
                model='gemini-2.5-flash',
                contents=[
                    types.Part.from_bytes(
                        data=image_bytes,
                        mime_type='image/jpeg',
                    ),
                    prompt
                ]
            )

            raw_text = response.text
            food_names = [item.strip() for item in raw_text.split(',') if item.strip()]
            store_image_and_response_to_mongo(
                image_bytes=image_bytes,
                response_text=food_names
            )

            return Response({'food_groups': food_names}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)        
        
        
def parse_nutrition_json_from_raw_text(raw_text: str) -> dict:
    """
    Try to extract a JSON object from a free-form or Markdown-wrapped LLM response.
    Supports:
      - ```json ... ``` fenced blocks
      - ``` ... ``` fenced blocks without the json hint
      - Raw text containing a JSON object (first balanced {...} block)
    Returns a dict (parsed JSON) on success or {"error": ...} on failure.
    """
    if not isinstance(raw_text, str) or not raw_text.strip():
        return {"error": "Empty response from model"}

    text = raw_text.strip()

    # 1) ```json ... ```
    match = re.search(r"```json\s*(.+?)\s*```", text, re.DOTALL | re.IGNORECASE)
    if not match:
        # 2) Any fenced block ``` ... ```
        match = re.search(r"```\s*(.+?)\s*```", text, re.DOTALL)
    if match:
        candidate = match.group(1).strip()
        try:
            return json.loads(candidate)
        except Exception:
            pass

    # 3) Heuristic: take substring from first '{' to last '}'
    start = text.find('{')
    end = text.rfind('}')
    if start != -1 and end != -1 and end > start:
        candidate = text[start:end + 1]
        try:
            return json.loads(candidate)
        except Exception as e:
            return {"error": "Failed to decode JSON", "details": str(e)}

    return {"error": "No JSON found in response"}
def get_meal_type():
    """Decide meal type based on current hour"""
    current_hour = datetime.now().hour
    if 6 <= current_hour < 12:
        return "Breakfast"
    elif 12 <= current_hour < 17:
        return "Lunch"
    else:
        return "Dinner"


def _make_json_safe(obj):
    """Return a JSON-serializable version of the given object."""
    if obj is None:
        return None
    if isinstance(obj, (str, int, float, bool)):
        if isinstance(obj, float) and (obj != obj or obj in (float('inf'), float('-inf'))):
            return 0.0
        return obj
    from datetime import datetime as _dt
    if isinstance(obj, _dt):
        return obj.isoformat()
    try:
        from bson import ObjectId
        if isinstance(obj, ObjectId):
            return str(obj)
    except Exception:
        pass
    try:
        from bson.binary import Binary as _Binary
        if isinstance(obj, _Binary):
            return f"<binary {len(obj)} bytes>"
    except Exception:
        pass
    if isinstance(obj, bytes):
        return f"<bytes {len(obj)} length>"
    if isinstance(obj, dict):
        return {str(k): _make_json_safe(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple, set)):
        return [_make_json_safe(x) for x in obj]
    return str(obj)


def generate_nutrition_from_text(food_description: str) -> Dict[str, Any]:
    """
    Use Gemini to infer nutrition details from a natural-language food description.
    Returns a dict aligned with the image-based Gemini response schema.
    """
    query = (food_description or "").strip()
    if not query:
        raise ValueError("Food description is required")

    prompt = f"""
    Analyze the following food description and respond with ONLY a JSON object using this schema:
    {{
      "food_name": "<main dish name>",
      "serving_size": "<estimated portion in American units (oz, lb, cups, tbsp, tsp, g)>",
      "meal_info": {{
        "calories": <number>,
        "protein": <number>,
        "carbs": <number>,
        "fat": <number>
      }},
      "nutrition_data": {{
        "energy": <number>,
        "fat": <number>,
        "saturated_fat": <number>,
        "poly_fat": <number>,
        "mono_fat": <number>,
        "cholestrol": <number>,
        "fiber": <number>,
        "sugar": <number>,
        "sodium": <number>,
        "potassium": <number>
      }}
    }}

    Rules:
    - Numbers must be plain (no units) and realistic.
    - Include every field even if the value is an estimate.
    - Do not add markdown, prose, or code fences.

    Food description:
    \"\"\"{query}\"\"\"
    """.strip()

    try:
        response = genai_client.models.generate_content(
            model='gemini-2.5-flash',
            contents=[prompt]
        )
    except Exception as exc:
        raise RuntimeError(f"Gemini text nutrition lookup failed: {exc}") from exc

    if hasattr(response, 'candidates') and response.candidates:
        first_candidate = response.candidates[0]
        parts_content = getattr(first_candidate, 'content', None)
        if parts_content and getattr(parts_content, 'parts', None):
            text_chunks = [getattr(part, 'text', '') for part in parts_content.parts if hasattr(part, 'text')]
            response_text = "\n".join(chunk for chunk in text_chunks if chunk)
        else:
            response_text = getattr(first_candidate, 'text', '') or str(first_candidate)
    elif hasattr(response, 'text'):
        response_text = response.text
    else:
        response_text = str(response)

    if not isinstance(response_text, str) or not response_text.strip():
        raise RuntimeError("Gemini returned an empty response for the provided description")

    try:
        parsed_data = json.loads(response_text)
    except Exception:
        parsed_data = parse_nutrition_json_from_raw_text(response_text)

    if not isinstance(parsed_data, dict):
        raise RuntimeError("Gemini did not return a valid nutrition JSON structure")

    parsed_data = _make_json_safe(parsed_data)

    meal_info = parsed_data.get("meal_info")
    if isinstance(meal_info, dict):
        meal_info.setdefault("meal", get_meal_type())
        meal_info["calories"] = safe_float(meal_info.get("calories"))
        meal_info["protein"] = safe_float(meal_info.get("protein"))
        meal_info["carbs"] = safe_float(meal_info.get("carbs"))
        meal_info["fat"] = safe_float(meal_info.get("fat"))
    else:
        parsed_data["meal_info"] = {
            "meal": get_meal_type(),
            "calories": safe_float(parsed_data.get("calories")),
            "protein": safe_float(parsed_data.get("protein")),
            "carbs": safe_float(parsed_data.get("carbs")),
            "fat": safe_float(parsed_data.get("fat"))
        }

    nutrition_data = parsed_data.get("nutrition_data")
    if isinstance(nutrition_data, dict):
        for key in ("energy", "fat", "saturated_fat", "poly_fat", "mono_fat", "cholestrol", "fiber", "sugar", "sodium", "potassium"):
            nutrition_data[key] = safe_float(nutrition_data.get(key))
    else:
        parsed_data["nutrition_data"] = {
            "energy": safe_float(parsed_data.get("energy")),
            "fat": safe_float(parsed_data.get("fat")),
            "saturated_fat": safe_float(parsed_data.get("saturated_fat")),
            "poly_fat": safe_float(parsed_data.get("poly_fat")),
            "mono_fat": safe_float(parsed_data.get("mono_fat")),
            "cholestrol": safe_float(parsed_data.get("cholestrol")),
            "fiber": safe_float(parsed_data.get("fiber")),
            "sugar": safe_float(parsed_data.get("sugar")),
            "sodium": safe_float(parsed_data.get("sodium")),
            "potassium": safe_float(parsed_data.get("potassium"))
        }

    parsed_data.setdefault("food_name", query)
    parsed_data.setdefault("serving_size", "1 serving")
    parsed_data.setdefault("image_url", None)
    parsed_data.setdefault("source", "text_query")

    return parsed_data


class ExtractAllInfoAPIView(APIView):
    parser_classes = [MultiPartParser]
    # Bypass DRF auth/permissions here; we manually validate JWT in the handler
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        # Early print to confirm the request reached this view
        print('[NutritionInfo][HIT]', {'method': getattr(request, 'method', None), 'path': getattr(request, 'path', None)}, flush=True)
        # Optional dry-run to verify routing without touching files/parsers
        try:
            if request.GET.get('dryrun') == '1':
                print('[NutritionInfo][DRYRUN]', flush=True)
                return Response({"status": "ok", "data": {"ping": "pong"}}, status=status.HTTP_200_OK)
        except Exception:
            # Ignore GET access issues on request
            pass

        # Print basic request info
        raw_auth = request.META.get('HTTP_AUTHORIZATION', '')
        redacted_auth = 'Bearer ***' if raw_auth.startswith('Bearer ') else ('***' if raw_auth else '')
        print('[NutritionInfo][REQ]', {
            'method': getattr(request, 'method', None),
            'path': getattr(request, 'path', None),
            'auth_present': bool(raw_auth),
            'auth': redacted_auth,
            'content_type': request.META.get('CONTENT_TYPE'),
        }, flush=True)

        # 1. Authenticate
        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            print('[NutritionInfo][AUTH][ERR]', getattr(error_response, 'data', None), flush=True)
            return error_response
        print('[NutritionInfo][AUTH]', {'user_id': user_id}, flush=True)

        # 2. Validate image
        if 'image' not in request.FILES:
            print('[NutritionInfo][REQ][ERR]', {'error': 'Missing image file'}, flush=True)
            return Response({'error': 'Missing image file'}, status=status.HTTP_400_BAD_REQUEST)
        image_file = request.FILES['image']
        if getattr(image_file, 'size', 0) == 0:
            print('[NutritionInfo][REQ][ERR]', {'error': 'Image file is empty'}, flush=True)
            return Response({'error': 'Image file is empty'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # 3. Read file
            filename = f"user_{user_id}/{timezone.now().strftime('%Y%m%d%H%M%S')}_{image_file.name}"
            path = default_storage.save(filename, ContentFile(image_file.read()))
            image_url = request.build_absolute_uri(default_storage.url(path))
            print('[NutritionInfo][FILE]', {'saved_path': path, 'image_url': image_url}, flush=True)

            # 4. Re-read the file bytes for AI analysis
            with default_storage.open(path, "rb") as f:
                image_bytes = f.read()
            print('[NutritionInfo][FILE]', {'bytes_len': len(image_bytes)}, flush=True)

            # 4. Prompt for Gemini
            prompt = """
            Analyze the uploaded food image and return ONLY a JSON object in the following format:

            {
              "food_name": "<main dish name>",
              "serving_size": "<estimated portion in American units (oz, lb, cups, tbsp, tsp, g)>",
              "meal_info": {
                "calories": <number>,
                "protein": <number>,
                "carbs": <number>,
                "fat": <number>
              },
              "nutrition_data": {
                "energy": <number>,
                "fat": <number>,
                "saturated_fat": <number>,
                "poly_fat": <number>,
                "mono_fat": <number>,
                "cholestrol": <number>,
                "fiber": <number>,
                "sugar": <number>,
                "sodium": <number>,
                "potassium": <number>
              }
            }

            Rules:
            - Use numbers only (no units) for nutrition values.
            - Always include all fields, even if estimated.
            - No extra explanation, no markdown, only JSON output.
            """

            # 5. Call Gemini
            response = genai_client.models.generate_content(
                model='gemini-2.5-flash',
                contents=[
                    types.Part.from_bytes(data=image_bytes, mime_type='image/jpeg'),
                    prompt
                ]
            )

            # 6. Extract response text
            if hasattr(response, 'candidates') and response.candidates:
                response_text = response.candidates[0].content.parts[0].text
            elif hasattr(response, 'text'):
                response_text = response.text
            else:
                response_text = str(response)
            snippet = response_text if len(response_text) <= 300 else response_text[:300] + '…'
            print('[NutritionInfo][AI][RAW]', {'snippet': snippet}, flush=True)

            # 7. Parse JSON
            try:
                parsed_data = json.loads(response_text)
            except Exception:
                parsed_data = parse_nutrition_json_from_raw_text(response_text)

            # Ensure dict and sanitize before use
            if not isinstance(parsed_data, dict):
                parsed_data = {'error': 'Model did not return JSON', 'raw': snippet}

            parsed_data = _make_json_safe(parsed_data)
            print('[NutritionInfo][AI][PARSED]', {
                'keys': list(parsed_data.keys()) if isinstance(parsed_data, dict) else None,
            }, flush=True)

            # 8. Insert meal type
            if "meal_info" in parsed_data:
                parsed_data["meal_info"]["meal"] = get_meal_type()
            else:
                parsed_data["meal_info"] = {
                    "meal": get_meal_type(),
                    "calories": parsed_data.get("calories", 0),
                    "protein": parsed_data.get("protein", 0),
                    "carbs": parsed_data.get("carbs", 0),
                    "fat": parsed_data.get("fat", 0)
                }
            parsed_data["image_url"] = image_url

            # 9. Save to DB
            image_id = store_image_and_response_to_mongo(
                user_id=user_id,
                image_bytes=image_bytes,
                response_text=response_text
            )

            # 10. Response
            response_payload = {
                "status": "success",
                "data": parsed_data,
                "timestamp": datetime.utcnow().isoformat(),
                "image_id": image_id
            }
            print('[NutritionInfo][RES]', {
                'keys': list(response_payload.keys()),
                'data_keys': list(parsed_data.keys()) if isinstance(parsed_data, dict) else None,
            }, flush=True)
            return Response(response_payload, status=status.HTTP_200_OK)

        except Exception as e:
            print('[NutritionInfo][ERR]', str(e), flush=True)
            print('[NutritionInfo][TRACE]', traceback.format_exc(), flush=True)
            return Response(
                {'error': 'Failed to process image', 'details': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

# ---------------------------------------------------------------------------
# Progress analytics API endpoints
# ---------------------------------------------------------------------------


class ProgressCaloriesAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        period = parse_period(request.query_params.get('period', 'daily'))
        start = request.query_params.get('start_date')
        end = request.query_params.get('end_date')

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        start_date, end_date = clamp_date_range(period, start, end)
        print('[ProgressCalories][REQ]', {
            'user_id': user_id,
            'period': period,
            'start': start,
            'end': end,
            'resolved_start': start_date.strftime('%Y-%m-%d'),
            'resolved_end': end_date.strftime('%Y-%m-%d')
        }, flush=True)
        grouped = fetch_grouped_logs_for_user(user_id, start_date, end_date)
        payload = build_calories_series(grouped)
        payload['period'] = period
        payload['start_date'] = start_date.strftime('%Y-%m-%d')
        payload['end_date'] = end_date.strftime('%Y-%m-%d')
        print('[ProgressCalories][RES]', {
            'labels_len': len(payload.get('labels', [])),
            'entries_len': len(payload.get('entries', [])),
            'series_keys': list((payload.get('series') or {}).keys()),
            'summary': payload.get('summary')
        }, flush=True)
        return Response(payload, status=status.HTTP_200_OK)


class ProgressMacrosAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        period = parse_period(request.query_params.get('period', 'daily'))
        start = request.query_params.get('start_date')
        end = request.query_params.get('end_date')

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        start_date, end_date = clamp_date_range(period, start, end)
        print('[ProgressMacros][REQ]', {
            'user_id': user_id,
            'period': period,
            'start': start,
            'end': end,
            'resolved_start': start_date.strftime('%Y-%m-%d'),
            'resolved_end': end_date.strftime('%Y-%m-%d')
        }, flush=True)
        grouped = fetch_grouped_logs_for_user(user_id, start_date, end_date)
        payload = build_macros_series(grouped)
        payload['period'] = period
        payload['start_date'] = start_date.strftime('%Y-%m-%d')
        payload['end_date'] = end_date.strftime('%Y-%m-%d')
        print('[ProgressMacros][RES]', {
            'labels_len': len(payload.get('labels', [])),
            'entries_len': len(payload.get('entries', [])),
            'series_keys': list((payload.get('series') or {}).keys()),
            'summary_len': len(payload.get('summary', []))
        }, flush=True)
        return Response(payload, status=status.HTTP_200_OK)


class ProgressNutrientsAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        period = parse_period(request.query_params.get('period', 'daily'))
        start = request.query_params.get('start_date')
        end = request.query_params.get('end_date')

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        start_date, end_date = clamp_date_range(period, start, end)
        print('[ProgressNutrients][REQ]', {
            'user_id': user_id,
            'period': period,
            'start': start,
            'end': end,
            'resolved_start': start_date.strftime('%Y-%m-%d'),
            'resolved_end': end_date.strftime('%Y-%m-%d')
        }, flush=True)
        grouped = fetch_grouped_logs_for_user(user_id, start_date, end_date)
        payload = build_nutrients_map(grouped)
        payload['period'] = period
        payload['start_date'] = start_date.strftime('%Y-%m-%d')
        payload['end_date'] = end_date.strftime('%Y-%m-%d')
        print('[ProgressNutrients][RES]', {
            'highlights_len': len(payload.get('highlights', [])),
            'detail_keys': len((payload.get('detail') or {})),
        }, flush=True)
        return Response(payload, status=status.HTTP_200_OK)


class ProgressAnalyticsAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        period = parse_period(request.query_params.get('period', 'daily'))
        start = request.query_params.get('start_date')
        end = request.query_params.get('end_date')

        user_id, error_response = get_user_id_from_token(request)
        if error_response:
            return error_response

        start_date, end_date = clamp_date_range(period, start, end)
        print('[ProgressAnalytics][REQ]', {
            'user_id': user_id,
            'period': period,
            'start': start,
            'end': end,
            'resolved_start': start_date.strftime('%Y-%m-%d'),
            'resolved_end': end_date.strftime('%Y-%m-%d')
        }, flush=True)
        grouped = fetch_grouped_logs_for_user(user_id, start_date, end_date)
        calories_payload = build_calories_series(grouped)
        macros_payload = build_macros_series(grouped)
        nutrients_payload = build_nutrients_map(grouped)
        analytics = build_progress_analytics(calories_payload, macros_payload, nutrients_payload)

        response_payload = {
            'period': period,
            'start_date': start_date.strftime('%Y-%m-%d'),
            'end_date': end_date.strftime('%Y-%m-%d'),
            'summary': analytics,
        }
        return Response(response_payload, status=status.HTTP_200_OK)

def clean_gemini_raw_json(raw_text: str) -> dict:
    """
    Extract and parse a JSON object from a Markdown-style code block returned by Gemini.
    """
    try:
        # Remove code block markers and extract the inner JSON
        cleaned = re.sub(r'^```json|```$', '', raw_text.strip(), flags=re.MULTILINE).strip()
        return json.loads(cleaned)
    except Exception as e:
        return {"error": "Failed to parse JSON", "details": str(e), "raw_text": raw_text}
    
#for email password verification.
class CheckEmailPasswordAPIView(APIView):
    parser_classes = [MultiPartParser]

    def post(self, request):
        # username = "soumya-123"
        password = "Soumya"
        # encoded_username = urllib.parse.quote_plus(username)
        encoded_password = urllib.parse.quote_plus(password)
        connection_string=f"mongodb+srv://{username}:{encoded_password}@cluster0.zaytioc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
        # connection_string=f"mongodb+srv://soumya-123:{encoded_password}@cluster0.zaytioc.mongodb.net/"
        # Connect to MongoDB
        client = MongoClient(connection_string)
        db = client["Nutrition"]
        collection = db["user-info"]
        email = request.data.get("email")
        password = request.data.get("password")

        if not email or not password:
            return Response({"message": "Email and password are required."}, status=status.HTTP_400_BAD_REQUEST)

        user = collection.find_one({"email": email})

        if not user:
            return Response({"message": "No email present."}, status=status.HTTP_404_NOT_FOUND)

        # If password is hashed in DB, use check_password:
        # if check_password(password, user["password"]):
        if user["password"] == password:
            return Response({"message": True}, status=status.HTTP_200_OK)
        else:
            return Response({"message": False}, status=status.HTTP_200_OK)


#for saving user info in to db.
class SaveUserProfileAPIView(APIView):
    """API to update user profile using user_id from JWT"""

    # permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            # DB Connection
            username = ""
            password = ""
            encoded_password = urllib.parse.quote_plus(password)
            # connection_string = (
            #     f"mongodb+srv://{username}:{encoded_password}"
            #     "@cluster0.zaytioc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
            # )
            # client = MongoClient(connection_string)
            db = client["nutrition-app"]
            user_collection = db["user-info"]

        except Exception as e:
            return Response(
                {"message": f"DB connection failed: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        user_id,error_response  = get_user_id_from_token(request)
        if error_response:
            return error_response
        try:
            data = request.data
            required_fields = [
                'gender', 'age', 'weight', 'height', 'primary_goal',
                'medical_condition', 'food_preference', 'mode_of_progress'
            ]

            # Check required fields
            if not all(field in data for field in required_fields):
                return Response(
                    {"message": "Missing required fields."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Profile data
            profile_data = {
                "gender": data.get("gender"),
                "age": int(data.get("age")),
                "weight": float(data.get("weight")),
                "height": float(data.get("height")),
                "primary_goal": data.get("primary_goal"),
                "medical_condition": data.get("medical_condition"),
                "food_preference": data.get("food_preference"),
                "mode_of_progress": data.get("mode_of_progress")
            }

            # Update profile using signup.user_id
            result = user_collection.update_one(
                {"signup.user_id": user_id},
                {"$set": {"user_profile": profile_data}},
                upsert=False
            )

            if result.matched_count == 0:
                return Response(
                    {"message": "User not found."},
                    status=status.HTTP_404_NOT_FOUND
                )

            return Response(
                {"message": "User profile updated successfully."},
                status=status.HTTP_200_OK
            )

        except Exception as e:
            return Response(
                {"message": f"Error updating profile: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
class TokenRefreshView(APIView):
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            if not refresh_token:
                return Response(
                    {'error': 'Refresh token is required'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            refresh = RefreshToken(refresh_token)
            access_token = str(refresh.access_token)
            
            # Optionally, you can create a new refresh token as well
            # new_refresh = RefreshToken.for_user(refresh.user)
            
            return Response({
                'access': access_token,
                # 'refresh': str(new_refresh)  # Uncomment if you want to rotate refresh tokens
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': 'Invalid refresh token', 'details': str(e)},
                status=status.HTTP_401_UNAUTHORIZED
            )

# OTP generation and OTP verification
class MobileOTPAPIView(APIView):
    def post(self, request):
        raw_mobile = request.data.get("mobile")
        otp = request.data.get("otp")
        print('[MobileOTP][REQ]', {'mobile': raw_mobile, 'otp_present': bool(otp)})

        if raw_mobile is None:
            return Response({"error": "Mobile number is required"}, status=status.HTTP_400_BAD_REQUEST)

        # Normalize by stripping everything except digits
        mobile = ''.join(filter(str.isdigit, raw_mobile))
        if mobile.startswith('91') and len(mobile) > 10:
            # Trim to last 10 digits for Indian numbers when a +91 prefix is included
            mobile = mobile[-10:]

        if len(mobile) != 10 or not mobile.isdigit():
            return Response({"error": "Invalid mobile number"}, status=status.HTTP_400_BAD_REQUEST)

        collection = db["mobile-otp"]

        if otp:
            # Verify OTP
            record = collection.find_one({"mobile": mobile})
            if not record:
                print('[MobileOTP][RES]', {'status': 'not_found', 'mobile': mobile})
                return Response({"error": "Mobile number not found"}, status=status.HTTP_404_NOT_FOUND)

            created_at = record.get("created_at")
            if created_at and datetime.utcnow() > created_at + timedelta(minutes=5):
                collection.delete_one({"mobile": mobile})
                print('[MobileOTP][RES]', {'status': 'expired', 'mobile': mobile})
                return Response({"error": "OTP expired"}, status=status.HTTP_400_BAD_REQUEST)

            stored_otp = record.get("otp")
            print('[MobileOTP][DB]', {
                'mobile': mobile,
                'stored_otp': stored_otp,
                'created_at': created_at.isoformat() if created_at else None
            })

            if stored_otp == otp:
                collection.delete_one({"mobile": mobile})
                print('[MobileOTP][RES]', {'status': 'verified', 'mobile': mobile})
                return Response({"message": "OTP is valid"}, status=status.HTTP_200_OK)
            else:
                print('[MobileOTP][RES]', {
                    'status': 'invalid',
                    'mobile': mobile,
                    'provided_otp': otp,
                    'stored_otp': stored_otp
                })
                return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        else:
            # Send OTP
            generated_otp = generate_otp()
            now = datetime.utcnow()
            # In real app, send OTP via SMS here
            collection.update_one(
                {"mobile": mobile},
                {"$set": {"otp": generated_otp, "created_at": now}},
                upsert=True
            )
            print('[MobileOTP][DB]', {'mobile': mobile, 'otp': generated_otp, 'created_at': now.isoformat()})
            print('[MobileOTP][RES]', {'status': 'sent', 'mobile': mobile})
            return Response({"message": "OTP sent successfully", "otp": generated_otp}, status=status.HTTP_200_OK)
        

class EmailOTPAPIView(APIView):
    def post(self, request):
        email = request.data.get("email")
        otp = request.data.get("otp")
        print('[EmailOTP][REQ]', {'email': email, 'otp_present': bool(otp)})
        username = ""
        password = ""
        encoded_username = urllib.parse.quote_plus(username)
        encoded_password = urllib.parse.quote_plus(password)
        connection_string=f"mongodb+srv://{encoded_username}:{encoded_password}@cluster0.zaytioc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
        # connection_string=f"mongodb+srv://soumya-123:{encoded_password}@cluster0.zaytioc.mongodb.net/"
        # Connect to MongoDB
        client = MongoClient(connection_string)
        db = client["Nutrition"]
        collection = db["otp-verification"]
        if not email:
            return Response({"error": "Email is required"}, status=status.HTTP_400_BAD_REQUEST)


        if otp:
            # Verify OTP
            record = collection.find_one({"email": email})
            if not record:
                return Response({"error": "Email not found"}, status=status.HTTP_404_NOT_FOUND)

            if record["otp"] == otp:
                return Response({"message": "OTP is valid"}, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        else:
            # Send OTP
            generated_otp = f"{random.randint(100000, 999999)}"
            # In real app, send OTP via SMS here
            collection.update_one(
                {"email": email},
                {"$set": {"otp": generated_otp}},
                upsert=True
            )
            return Response({"message": "OTP sent successfully", "otp": generated_otp}, status=status.HTTP_200_OK)
class BarcodeScanAPIView(APIView):
    # Bypass DRF auth/permissions; we manually validate JWT inside
    authentication_classes = []
    permission_classes = []
    parser_classes = [MultiPartParser]

    def post(self, request):
        try:
            print('[Barcode][HIT]', {'method': getattr(request, 'method', None), 'path': getattr(request, 'path', None)}, flush=True)
            # Step 1: Extract user_id from token
            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                print('[Barcode][AUTH][ERR]', getattr(error_response, 'data', None), flush=True)
                return error_response
            print('[Barcode][AUTH]', {'user_id': user_id}, flush=True)

            # Step 2: Get uploaded image
            image_file = request.FILES.get("image")
            if not image_file:
                print('[Barcode][REQ][ERR]', {'error': 'no_image'}, flush=True)
                return Response({"error": "Image file is required"}, status=400)

            raw_bytes = image_file.read()
            print('[Barcode][FILE]', {'size': len(raw_bytes)}, flush=True)

            # Step 3: Check if pyzbar is available
            if not PYZBARD_AVAILABLE:
                print('[Barcode][ENV][ERR]', {'pyzbar': False}, flush=True)
                return Response({"error": "Barcode scanning is not available on this system"}, status=501)

            # Step 3: Convert uploaded image to numpy array
            file_bytes = np.frombuffer(raw_bytes, np.uint8)
            image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
            if image is None:
                print('[Barcode][DECODE][ERR]', {'reason': 'cv2_imdecode_failed'}, flush=True)
                return Response({"error": "Failed to decode image"}, status=400)

            # Step 4: Decode barcode
            barcodes = pyzbar.decode(image)
            if not barcodes:
                print('[Barcode][DECODE]', {'found': 0}, flush=True)
                return Response({"error": "Invalid barcode. Try with correct barcode."}, status=404)

            barcode_data = barcodes[0].data.decode("utf-8")
            barcode_type = barcodes[0].type
            print('[Barcode][DECODE]', {'type': barcode_type, 'data': barcode_data}, flush=True)

            # Step 5: Fetch product data from OpenFoodFacts
            url = f"https://world.openfoodfacts.org/api/v0/product/{barcode_data}.json"
            response = requests.get(url, timeout=10)
            data = response.json()
            print('[Barcode][OFF]', {'status': data.get('status')}, flush=True)

            if data.get("status") != 1:
                return Response({"error": "Invalid barcode. Try with correct barcode."}, status=404)

            product = data.get("product", {})
            nutriments = product.get("nutriments", {})
            # Nutrition Data Mapping from actual keys
            nutrition_data = {
                "calories": nutriments.get("energy-kcal_100g"),
                "protein": nutriments.get("proteins_100g"),
                "carbs": nutriments.get("carbohydrates_100g"),
                "fat": nutriments.get("fat_100g"),
                "energy": nutriments.get("energy_100g"),

                "saturated_fat": nutriments.get("saturated-fat_100g"),
                "poly_fat": nutriments.get("polyunsaturated-fat_100g"),
                "mono_fat": nutriments.get("monounsaturated-fat_100g"),
                "trans_fat": nutriments.get("trans-fat_100g"),

                "cholestrol": nutriments.get("cholesterol_100g"),
                "fiber": nutriments.get("fiber_100g"),
                "sugar": nutriments.get("sugars_100g"),

                "sodium": nutriments.get("sodium_100g"),
                "potassium": nutriments.get("potassium_100g"),
                "calcium": nutriments.get("calcium_100g"),
                "iron": nutriments.get("iron_100g")
            }
            print('[Barcode][NUTRIENTS]', {'keys': list(nutrition_data.keys())}, flush=True)

            # Serving size fallback
            serving_size = product.get("serving_size", "Full Served • 250 g")
            print('[Barcode][SERVING]', {'serving_size': serving_size}, flush=True)

            # Store in Mongo (optional)
            try:
                image_id = store_image_and_response_to_mongo(
                    user_id=user_id,
                    image_bytes=raw_bytes,
                    response_text=json.dumps(nutrition_data)
                )
            except Exception as e:
                print('[Barcode][STORE][ERR]', str(e), flush=True)
                image_id = None

            # Final structured response
            result = {
                "status": "success",
                "data": {
                    "food_name": product.get("product_name", "Unknown Food"),
                    "serving_size": serving_size,
                    "image_url": product.get("image_url", "https://example.com/images/default.png"),
                    "nutrition_data": nutrition_data,
                },
                "timestamp": timezone.now().isoformat(),
                "image_id": image_id,
            }
            print('[Barcode][RES]', {'keys': list(result.keys())}, flush=True)
            return Response(result, status=200)

        except AuthenticationFailed as e:
            print('[Barcode][ERR][AUTH]', str(e), flush=True)
            return Response({"error": "Authentication failed", "details": str(e)}, status=401)
        except Exception as e:
            print('[Barcode][ERR]', str(e), flush=True)
            print('[Barcode][TRACE]', traceback.format_exc(), flush=True)
            return Response({"error": str(e)}, status=500)
#user signup details

class LoginAPIView(APIView):
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        print('[Login][REQ]', {'email': email})
        
        if not email or not password:
            return Response(
                {'error': 'Please provide both email and password'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
          
            
            cache_key = f"user_auth:{email}"
            user = cache.get(cache_key)

            if user is None:
                user = user_info_collection.find_one({"_id": email})
                if user:
                    cache.set(cache_key, user, timeout=300)

            if not user:
                print('[Login][RES]', {'status': 404, 'reason': 'user_not_found'})
                return Response(
                    {'error': 'User not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Get the signup data which contains the password
            signup_data = user.get('signup', {})
            if not signup_data:
                print('[Login][RES]', {'status': 500, 'reason': 'invalid_user_data'})
                return Response(
                    {'error': 'Invalid user data'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
                
            # Get the hashed password from the signup data

            hashed_password = signup_data.get('encrypted_pw')
            
            # Verify the password using Django's check_password
            if not check_password(password, hashed_password):
                print('[Login][RES]', {'status': 401, 'reason': 'invalid_credentials'})
                return Response(
                    {'error': 'Invalid Email and Password credentials'}, 
                    status=status.HTTP_401_UNAUTHORIZED
                )
            
            # Generate tokens manually without using Django's user model
            
            # Get user ID from signup data
            user_id = str(signup_data.get('user_id'))
            # Create token payload
            refresh = RefreshToken()
            refresh['user_id'] = user_id
            refresh['email'] = email
            
            # Set expiration time (~10 years for refresh token, 1 hour for access token)
            refresh.set_exp(lifetime=timedelta(days=3650))
            access_token = refresh.access_token
            access_token.set_exp(lifetime=timedelta(hours=1))
            
            cache.set(cache_key, user, timeout=300)

            user_payload = {
                'name': signup_data.get('full_name', ''),
                'email': email,
                'phone': signup_data.get('mobile_number', ''),
                'user_id': user_id,
            }

            return Response({
                'message': 'Login successful',
                'access': str(access_token),
                'refresh': str(refresh),
                'user': user_payload,
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            print('[Login][RES]', {'status': 200, 'message': 'success'})
            return Response(
                {'error': f'An error occurred during login: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CustomTokenRefreshView(APIView):
    """Issue new access and refresh tokens without hitting Django User model.
    Uses our CustomTokenRefreshSerializer which only validates/rotates the refresh JWT.
    """
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        try:
            serializer = CustomTokenRefreshSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        except InvalidToken as e:
            return Response({"detail": str(e)}, status=status.HTTP_401_UNAUTHORIZED)
        except Exception as e:
            return Response({"detail": "Token refresh failed", "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class SignupAPIView(APIView):
    @staticmethod
    def generate_unique_user_id():
        """Generate unique ID like USR12345 and check DB for uniqueness"""
        while True:
            user_id = "USR" + "".join(random.choices(string.digits, k=5))
            exists = user_info_collection.find_one({"signup.user_id": user_id})
            if not exists:  # unique
                return user_id

    def encrypt_password(self, password: str) -> str:
       """
       Securely hash the password using Django's recommended hashing.
       """
       return make_password(password)
    def post(self, request):

        try:
            # Extract fields from request data
            email = request.data.get("email")
            full_name = request.data.get("full_name")
            mobile_number = request.data.get("mobile_number")
            password = request.data.get("password")
            # print(email,full_name,mobile_number,password)
            if not email:
                return Response({"error": "Email is required"}, status=status.HTTP_400_BAD_REQUEST)

            # Generate unique user_id
            user_id = self.generate_unique_user_id()
            # Encrypt password (here using simple placeholder)
            encrypted_pw = self.encrypt_password(password)

            # Build data format
            try:
                user_data = {
                    "_id": email,   # email as unique identifier
                    "signup": {
                        "full_name": full_name,
                        "mobile_number": mobile_number,
                        "encrypted_pw": encrypted_pw,
                        "user_id": user_id,
                    },
                    "user_profile": None  # later you can update with profile info
                    }
                user_info_collection.insert_one(user_data)
                refresh = RefreshToken()
                refresh['user_id'] = user_id
                refresh['email'] = email
                refresh.set_exp(lifetime=timedelta(days=7))
                access_token = refresh.access_token
                access_token.set_exp(lifetime=timedelta(hours=1))

                print('[Signup][RES]', {'status': 200, 'message': 'Signup successful'})
                user_payload = {
                    'name': full_name or '',
                    'email': email,
                    'phone': mobile_number or '',
                    'user_id': user_id,
                }
                return Response({
                    'message': 'Signup successful',
                    'profile_setup_done': False,
                    'access': str(access_token),
                    'refresh': str(refresh),
                    'user': user_payload,
                }, status=status.HTTP_200_OK)
            except Exception as insert_error:
                existing_user = user_info_collection.find_one({"_id": email})
                if existing_user:
                    print('[Signup][RES]', {'status': 409, 'note': 'user already exists'})
                    # Issue a fresh token pair for existing user
                    existing_user_id = existing_user.get("signup", {}).get("user_id")
                    refresh = RefreshToken()
                    refresh['user_id'] = existing_user_id
                    refresh['email'] = email
                    refresh.set_exp(lifetime=timedelta(days=7))
                    access_token = refresh.access_token
                    access_token.set_exp(lifetime=timedelta(hours=1))

                    user_payload = {
                        'name': existing_user.get('signup', {}).get('full_name', ''),
                        'email': email,
                        'phone': existing_user.get('signup', {}).get('mobile_number', ''),
                        'user_id': existing_user_id or '',
                    }

                    return Response({
                        'message': 'User already exists',
                        'access': str(access_token),
                        'refresh': str(refresh),
                        'profile_setup_done': True,
                        'user': user_payload,
                    }, status=status.HTTP_200_OK)

                print('[Signup][RES]', {'status': 500, 'error': str(insert_error)})
                return Response({"error": str(insert_error)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        except Exception as e:
            print('[Signup][RES]', {'status': 500, 'error': str(e)})
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    
#get user logs.

class UserDailySummaryAPIView(APIView):
    """API to fetch daily nutritional summary for a user."""
    # Bypass DRF authentication here; we manually validate JWT via header.
    authentication_classes = []
    permission_classes = []

    # def get(self, request, date_str):
    #     user_id,error_response  = get_user_id_from_token(request)
    #     if error_response:
    #         return error_response
    #     user_doc = user_activity_collection.find_one({"user_id": user_id})

    #     if not user_doc:
    #         return Response({"error": "No logs found"}, status=status.HTTP_404_NOT_FOUND)

    #     # Find logs for requested date
    #     for log in user_doc.get("logs", []):
    #         if log.get("date") == date_str:
    #             summary, meal_wise = self.aggregate_nutrition(log.get("entries", []))
    #             return Response({
    #                 "date": date_str,
    #                 "summary": summary,
    #                 "meal_wise": meal_wise
    #             }, status=status.HTTP_200_OK)
    #     print("log",user_doc)
    #     return Response({"error": f"No logs found for {date_str}"}, status=status.HTTP_404_NOT_FOUND)

    # def aggregate_nutrition(self, entries):
    #     """Aggregate nutrition values across entries."""
    #     totals = {"calories": 0.0, "protein_g": 0.0, "fats_g": 0.0, "carbs_g": 0.0}
    #     meal_wise = {
    #         "breakfast": {"calories": 0.0, "protein_g": 0.0, "fats_g": 0.0, "carbs_g": 0.0},
    #         "lunch": {"calories": 0.0, "protein_g": 0.0, "fats_g": 0.0, "carbs_g": 0.0},
    #         "dinner": {"calories": 0.0, "protein_g": 0.0, "fats_g": 0.0, "carbs_g": 0.0}
    #     }

    #     for entry in entries:
    #         nutrition = entry["nutrition_data"].get("nutritional_value", {})
    #         meal_type = entry["nutrition_data"].get("meal_type", None)

    #         for key, value in nutrition.items():
    #             try:
    #                 num = float(value.split()[0])  # extract numeric part
    #             except (ValueError, AttributeError):
    #                 continue

    #             # update totals
    #             if key in totals:
    #                 totals[key] += num

    #             # update meal_wise if meal_type exists
    #             if meal_type and meal_type in meal_wise:
    #                 meal_wise[meal_type][key] += num

    #     # Clean up: if no meal values present, keep them as empty
    #     for meal in meal_wise:
    #         if all(v == 0.0 for v in meal_wise[meal].values()):
    #             meal_wise[meal] = {}

    #     return totals, meal_wise
    def get(self, request, date_str):
        print("date_str",date_str)
        print('Daily summary request', request)
        # Debug: request and token info (redact token)
        try:
            raw_auth = request.META.get('HTTP_AUTHORIZATION', '')
            redacted_auth = 'Bearer ***' if raw_auth.startswith('Bearer ') else ('***' if raw_auth else '')
            print('[GetFoodLog][REQ]', {
                'date': date_str,
                'auth_present': bool(raw_auth),
                'auth': redacted_auth,
                'method': getattr(request, 'method', None),
                'path': getattr(request, 'path', None),
                'content_type': request.META.get('CONTENT_TYPE'),
                'accept': request.META.get('HTTP_ACCEPT'),
            }, flush=True)

            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                print('[GetFoodLog][AUTH][ERR]', {'date': date_str, 'error': getattr(error_response, 'data', None)})
                return error_response

            print('[GetFoodLog][AUTH]', {'user_id': user_id, 'date': date_str}, flush=True)

            user_doc = user_activity_collection.find_one({"user_id": user_id})
            if not user_doc:
                print('[GetFoodLog][DB]', {'user_id': user_id, 'found': False}, flush=True)
                return Response({"error": "No logs found"}, status=status.HTTP_404_NOT_FOUND)

            logs_list = user_doc.get("logs")
            if not isinstance(logs_list, list):
                print('[GetFoodLog][DB][WARN]', {'user_id': user_id, 'logs_type': type(logs_list).__name__}, flush=True)
                logs_list = []
            else:
                print('[GetFoodLog][DB]', {'user_id': user_id, 'logs_count': len(logs_list)}, flush=True)

            entries_raw: List[dict] = []
            food_entries: List[dict] = []
            total_calories = 0.0
            matched_log: Optional[dict] = None

            for log in logs_list:
                if not isinstance(log, dict):
                    continue
                if log.get("date") == date_str:
                    matched_log = log
                    candidate_entries = log.get("entries") or []
                    if not isinstance(candidate_entries, list):
                        print('[GetFoodLog][DB][WARN]', {'reason': 'entries_not_list'})
                        break
                    entries_raw = candidate_entries
                    for entry in entries_raw:
                        if not isinstance(entry, dict):
                            continue
                        foodlog = entry.get("foodlog")
                        if not isinstance(foodlog, dict):
                            continue

                        food_entries.append(entry)

                        # Prefer meal_info calories, else nutrition_data calories/energy
                        calories = None
                        mi = foodlog.get("meal_info")
                        if isinstance(mi, dict) and "calories" in mi:
                            calories = mi["calories"]
                        else:
                            nd = foodlog.get("nutrition_data")
                            if isinstance(nd, dict):
                                calories = nd.get("calories") or nd.get("energy")

                        if calories is not None:
                            try:
                                total_calories += float(calories)
                            except (TypeError, ValueError):
                                continue
                    break

            print('[GetFoodLog][RES]', {
                'date': date_str,
                'entries': len(food_entries),
                'calories_total': total_calories,
                'entries_sample': food_entries[:1],
            }, flush=True)
            # Sanitize entries to ensure JSON serializable
            def make_json_safe(obj):
                if obj is None:
                    return None
                if isinstance(obj, (str, int, float, bool)):
                    # Avoid returning NaN/Infinity
                    if isinstance(obj, float) and (obj != obj or obj in (float('inf'), float('-inf'))):
                        return 0.0
                    return obj
                from datetime import datetime as _dt
                if isinstance(obj, _dt):
                    return obj.isoformat()
                try:
                    from bson import ObjectId
                    if isinstance(obj, ObjectId):
                        return str(obj)
                except Exception:
                    pass
                try:
                    from bson.binary import Binary as _Binary
                    if isinstance(obj, _Binary):
                        return f"<binary {len(obj)} bytes>"
                except Exception:
                    pass
                if isinstance(obj, bytes):
                    return f"<bytes {len(obj)} length>"
                if isinstance(obj, dict):
                    return {str(k): make_json_safe(v) for k, v in obj.items()}
                if isinstance(obj, (list, tuple, set)):
                    return [make_json_safe(x) for x in obj]
                # Fallback to string
                return str(obj)

            safe_entries = make_json_safe(food_entries)

            wellness_info = {
                "question": DEFAULT_WELLNESS_QUESTION,
                "options": list(DEFAULT_WELLNESS_OPTIONS),
                "selected": ""
            }

            if isinstance(matched_log, dict):
                log_wellness = matched_log.get("wellness")
                if isinstance(log_wellness, dict):
                    question = log_wellness.get("question") or DEFAULT_WELLNESS_QUESTION
                    options = log_wellness.get("options")
                    if isinstance(options, list) and options:
                        wellness_options = [str(opt) for opt in options]
                    else:
                        wellness_options = list(DEFAULT_WELLNESS_OPTIONS)
                    selected = log_wellness.get("selected") or log_wellness.get("mood") or ""
                    wellness_info = {
                        "question": str(question),
                        "options": wellness_options,
                        "selected": str(selected),
                    }

            response_payload = {
                "date": date_str,
                "foodlogs": safe_entries,
                "Total calories": total_calories,
                "Calories consumed": total_calories,
                "wellness_prompt": make_json_safe(wellness_info),
            }
            print('[GetFoodLog][RES][PAYLOAD]', {
                'keys': list(response_payload.keys()),
                'foodlogs_len': len(food_entries),
            }, flush=True)
            return Response(response_payload, status=status.HTTP_200_OK)
        except Exception as e:
            # Catch-all to avoid 500s without context
            print('[GetFoodLog][ERR]', {'date': date_str, 'exception': str(e)}, flush=True)
            print('[GetFoodLog][TRACE]', traceback.format_exc(), flush=True)
            return Response(
                {"error": "Failed to fetch food logs", "details": str(e), "date": date_str},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
# {{ ... }}
#food predictions.

class GetFoodPredictionsAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, date_str):
        try:
            # ✅ Step 1: Extract user_id
            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                return error_response
        except Exception as e:
            return Response(
                {"error": f"Authentication failed: {str(e)}"},
                status=status.HTTP_401_UNAUTHORIZED
            )

        # ✅ Step 2: Fetch user activity from MongoDB
        user_doc = user_activity_collection.find_one({"user_id":user_id})
        if not user_doc:
            return Response(
                {"error": "No data found for this user"},
                status=status.HTTP_404_NOT_FOUND
            )

        food_list = []
        nutrition_list = []
        totals = {"calories": 0.0, "fats_g": 0.0}

        # ✅ Step 3: Search logs by date
        for log in user_doc.get("logs", []):
            if log.get("date") == date_str:
                for entry in log.get("entries", []):
                    nutrition_data = entry.get("foodlog", {})
                    food_list.append(nutrition_data.get("food_name",''))
                    # print(nutrition_data.get('food_name'))
                    # food_list.extend(nutrition_data.get("nutrition_data",'').split())
                    nutri = nutrition_data.get("nutrition_data", {})

                    # Add to list
                    nutrition_list.append(nutri)

                    # Aggregate totals (remove units like "kcal" / "g")
                    try:
                        totals["calories"] += float(nutri.get("energy", "0"))
                        totals["fats_g"] += float(nutri.get("fat", "0"))
                    except Exception:
                        continue
        if not food_list:
           result = {
            "date": date_str,
            "user_id": user_id,
            "recommendations":  ["Oatmeal with Berries","Sweet Potato and Black Bean Bowl","Whole Wheat Pasta with Marinara"]
           }

           return Response(result, status=status.HTTP_200_OK)

        # ✅ Step 4: Build LLM prompt
        prompt = f"""
        a user has consumed the following foods:
        Foods: {food_list}
        Nutrition Summary (so far):
        - Calories: {totals['calories']} kcal
        - Fats: {totals['fats_g']} g

        Now, recommend exactly 3 short and precise U.S.-based food recipes that balance the nutrition.  
        Important:
        - Only return the food names.
        - Return them as a Python-style list, comma-separated.
        - Output format must be exactly like:

          {{
          "recommend_food": ["Food 1", "Food 2", "Food 3"]
           }}
        """

        # ✅ Step 5: Call Gemini LLM
        try:
            response = genai_client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                types.Content(
                    role="user",
                    parts=[{"text": prompt}]
                )
            ]
            )
            raw_text  = response.candidates[0].content.parts[0].text
            llm_recommendations=re.sub(r"^```(?:json)?|```$", "", raw_text, flags=re.MULTILINE).strip()
            llm_recommendations = json.loads(llm_recommendations)
        except Exception as e:
            llm_recommendations = {"recommend_food": []}

        # ✅ Step 6: Final response
        result = {
            "date": date_str,
            "user_id": user_id,
            "recommendations": llm_recommendations['recommend_food']
        }

        return Response(result, status=status.HTTP_200_OK)
    
    
    
#gmail smtp otp based.
def generate_otp():
    otp = "123456"
    print('[EmailOTP][GEN]', {'otp': otp})
    return otp


def send_email(email, otp):
    """Send OTP via SMTP"""
    missing_credentials = []
    if not EMAIL_USER:
        missing_credentials.append("EMAIL_USER")
    if not EMAIL_PW:
        missing_credentials.append("EMAIL_PASS")

    if missing_credentials:
        print('[EmailOTP][SMTP][ERR]', {
            'error': 'Missing SMTP credentials',
            'missing': missing_credentials,
            'email': email,
        })
        return False, {
            "error": "Email service is not configured",
            "details": f"Missing credentials: {', '.join(missing_credentials)}",
        }

    try:
        print('[EmailOTP][SMTP][REQ]', {'email': email})
        server = smtplib.SMTP("smtp.gmail.com", 587, timeout=10)
        server.starttls()
        server.login(EMAIL_USER, EMAIL_PW)
        message = f"Subject: Your OTP Code\n\nYour OTP is {otp}"
        server.sendmail(EMAIL_USER, email, message)
        server.quit()
        print('[EmailOTP][SMTP][RES]', {'status': 'sent'})
        return True, None
    except Exception as e:
        print('[EmailOTP][SMTP][ERR]', {
            'error': str(e),
            'type': e.__class__.__name__,
            'email': email,
        })
        return False, {
            "error": "Failed to send OTP email",
            "details": str(e),
        }


class SendOtpAPIView(APIView):
    """Step 1: Send OTP"""

    def post(self, request):
        try:
            email = request.data.get("email")
            if not email:
                print('[EmailOTP][REQ][ERR]', {'reason': 'missing_email'})
                return Response({"error": "Email is required"}, status=status.HTTP_400_BAD_REQUEST)

            print('[EmailOTP][REQ]', {'email': email})
            otp = generate_otp()
            now = datetime.utcnow()

            # If email exists, update OTP
            otp_collection.update_one(
                {"email": email},
                {"$set": {"otp": otp, "created_at": now}},
                upsert=True
            )
            print('[EmailOTP][DB]', {'email': email, 'created_at': now.isoformat()})

            sent, error_payload = send_email(email, otp)
            if sent:
                # Include OTP in response for app's dev flow (UI reads it for convenience)
                print('[EmailOTP][RES]', {'status': 'sent'})
                return Response({"message": "OTP sent successfully", "otp": otp}, status=status.HTTP_200_OK)
            else:
                print('[EmailOTP][RES]', {'status': 'send_failed', 'email': email})
                if error_payload:
                    return Response(error_payload, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                return Response({"error": "Failed to send OTP"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        except Exception as e:
            print('[EmailOTP][RES][ERR]', {'error': str(e)})
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class VerifyOtpAPIView(APIView):
    """Step 2: Verify OTP"""

    def post(self, request):
        try:
            email = request.data.get("email")
            otp = request.data.get("otp")

            if not email or not otp:
                print('[EmailOTP][VERIFY][REQ][ERR]', {'reason': 'missing_fields'})
                return Response({"error": "Email and OTP are required"}, status=status.HTTP_400_BAD_REQUEST)

            print('[EmailOTP][VERIFY][REQ]', {'email': email, 'otp': otp})
            record = otp_collection.find_one({"email": email})

            if not record:
                print('[EmailOTP][VERIFY][RES]', {'status': 'not_found', 'email': email})
                return Response({"error": "No OTP found for this email"}, status=status.HTTP_404_NOT_FOUND)

            # Check expiration
            created_at = record.get("created_at")
            if created_at and datetime.utcnow() > created_at + timedelta(minutes=5):
                otp_collection.delete_one({"email": email})
                print('[EmailOTP][VERIFY][RES]', {'status': 'expired', 'email': email})
                return Response({"error": "OTP expired"}, status=status.HTTP_400_BAD_REQUEST)

            stored_otp = record.get("otp")
            print('[EmailOTP][VERIFY][DB]', {
                'email': email,
                'stored_otp': stored_otp,
                'created_at': created_at.isoformat() if created_at else None
            })
            # Check OTP
            if stored_otp == otp:
                otp_collection.delete_one({"email": email})
                print('[EmailOTP][VERIFY][RES]', {'status': 'verified', 'email': email})
                return Response({"message": "OTP verification successful"}, status=status.HTTP_200_OK)
            else:
                print('[EmailOTP][VERIFY][RES]', {
                    'status': 'invalid',
                    'email': email,
                    'provided_otp': otp,
                    'stored_otp': stored_otp
                })
                return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            print('[EmailOTP][VERIFY][ERR]', {'error': str(e)})
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



class HomePageView(View):
    template_name = 'nutritionApp/index.html'

    def get(self, request):
        return render(request, self.template_name)


class CustomTokenRefreshView(TokenViewBase):
    serializer_class = CustomTokenRefreshSerializer


"""with all endpoint forms"""
        # return render(request, 'homepage.html')


class UpdateWellnessAPIView(APIView):
    """API to update wellness/mood selection for a specific date."""
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        print('[UpdateWellness][HIT]', {
            'method': getattr(request, 'method', None),
            'path': getattr(request, 'path', None),
        }, flush=True)

        try:
            user_id, error_response = get_user_id_from_token(request)
            if error_response:
                print('[UpdateWellness][AUTH][ERR]', getattr(error_response, 'data', None), flush=True)
                return error_response

            payload = request.data or {}
            raw_mood = payload.get("mood")
            if raw_mood is None or str(raw_mood).strip() == "":
                return Response({"error": "mood is required"}, status=status.HTTP_400_BAD_REQUEST)

            mood = str(raw_mood).strip()

            raw_date = payload.get("date")
            if isinstance(raw_date, str) and raw_date.strip():
                date_str = raw_date.strip()
            else:
                date_str = now().strftime("%Y-%m-%d")

            raw_question = payload.get("question")
            if isinstance(raw_question, str) and raw_question.strip():
                question = raw_question.strip()
            else:
                question = DEFAULT_WELLNESS_QUESTION

            raw_options = payload.get("options")
            if isinstance(raw_options, list) and raw_options:
                options = [str(option) for option in raw_options if option is not None]
                if not options:
                    options = list(DEFAULT_WELLNESS_OPTIONS)
            else:
                options = list(DEFAULT_WELLNESS_OPTIONS)

            wellness_doc: Dict[str, Any] = {
                "question": question,
                "options": options,
                "selected": mood,
            }

            user_doc = user_activity_collection.find_one({"user_id": user_id})
            if user_doc:
                logs = user_doc.get("logs") or []
                if not isinstance(logs, list):
                    logs = []
                log_found = False
                for log in logs:
                    if not isinstance(log, dict):
                        continue
                    if log.get("date") == date_str:
                        log["wellness"] = wellness_doc
                        entries = log.get("entries")
                        if not isinstance(entries, list):
                            log["entries"] = []
                        log_found = True
                        break
                if not log_found:
                    logs.append({
                        "date": date_str,
                        "entries": [],
                        "wellness": wellness_doc,
                    })
                user_activity_collection.update_one(
                    {"user_id": user_id},
                    {"$set": {"logs": logs}},
                    upsert=True,
                )
            else:
                user_activity_collection.insert_one({
                    "user_id": user_id,
                    "logs": [
                        {
                            "date": date_str,
                            "entries": [],
                            "wellness": wellness_doc,
                        }
                    ],
                })

            response_payload = {
                "message": "Wellness updated successfully",
                "date": date_str,
                "wellness_prompt": wellness_doc,
            }
            print('[UpdateWellness][RES]', response_payload, flush=True)
            return Response(response_payload, status=status.HTTP_200_OK)
        except Exception as e:
            print('[UpdateWellness][ERR]', str(e), flush=True)
            print('[UpdateWellness][TRACE]', traceback.format_exc(), flush=True)
            return Response(
                {"error": "Failed to update wellness", "details": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
