from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from .views import (
    SignupAPIView, OTPVerifyView, MultiFoodDetectionAPIView, ExtractAllInfoAPIView,
    SaveUserProfileAPIView, CheckEmailPasswordAPIView, MobileOTPAPIView,
    EmailOTPAPIView, BarcodeScanAPIView, LoginAPIView, LogFoodAPIView,
    GetFoodLogsAPIView,UserDailySummaryAPIView,SendOtpAPIView,VerifyOtpAPIView,GetFoodPredictionsAPIView,
    LogWaterAPIView,GetWaterLogAPIView,UpdateWellnessAPIView, CustomTokenRefreshView,
    ProgressCaloriesAPIView, ProgressMacrosAPIView, ProgressNutrientsAPIView, ProgressAnalyticsAPIView,
    ManualLogSearchAPIView, ManualLogPredictAPIView, ManualLogSaveAPIView, ManualLogCaptureAPIView, ManualLogSearchTestAPIView, FoodLogSearchAPIView,
    DietPlanListCreateAPIView, GetWaterLogAPIView,
    GetWaterHistoryAPIView,WeightDashboardAPIView, BodyScanAPIView, BodyScanInsightAPIView,
    WorkoutListAPIView, WorkoutDetailAPIView, WorkoutCompleteAPIView, WorkoutSummaryAPIView
)

urlpatterns = [
    path('verify-otp/', OTPVerifyView.as_view(),name='verify_otp'),
    path('token/refresh/', CustomTokenRefreshView.as_view(),name='api_token_refresh'),
    path('token/refresh', CustomTokenRefreshView.as_view(),name='api_token_refresh_no_slash'),
    path('multifooddetection', MultiFoodDetectionAPIView.as_view(), name='multi_food_detection'),
    path('nutritioninfo', ExtractAllInfoAPIView.as_view(), name='nutritioninfo'),
    path('emailpasswordverify/', CheckEmailPasswordAPIView.as_view(), name='emailpasswordverify'),
    path('userprofileinfo', SaveUserProfileAPIView.as_view(), name='userprofileinfo'),
    path('mobileotp', MobileOTPAPIView.as_view(), name='mobileotp'),
    path('emailotp', EmailOTPAPIView.as_view(), name='emailotp'),
    path('barcodescan', BarcodeScanAPIView.as_view(), name='barcodescan'),
    path('barcodescan/', BarcodeScanAPIView.as_view(), name='barcodescan_slash'),
    path('signupdetails', SignupAPIView.as_view(), name='signupdetails'),
    path('login', LoginAPIView.as_view(), name='login'),
    
    # Food logging endpoints
    path('foodlog', LogFoodAPIView.as_view(), name='log_food'),
    path('waterlog', LogWaterAPIView.as_view(), name='waterlog'),
    # Support both with and without trailing slash to match mobile client
    path('getwaterlog/<str:date_str>/', GetWaterLogAPIView.as_view(), name='getwaterlog'),
    path('getwaterlog/<str:date_str>', GetWaterLogAPIView.as_view(), name='getwaterlog_no_slash'),
    path('waterlog/history', GetWaterHistoryAPIView.as_view(), name='waterlog_history'),
    path('waterlog/history/', GetWaterHistoryAPIView.as_view(), name='waterlog_history_slash'),
    path('getfoodlog/<str:date_str>/', UserDailySummaryAPIView.as_view(), name='get_log_food'),
    path('getfoodlog/<str:date_str>', UserDailySummaryAPIView.as_view(), name='get_log_food_no_slash'),
    path('updatewellness', UpdateWellnessAPIView.as_view(), name='update_wellness'),
    # path('food/logs', GetFoodLogsAPIView.as_view(), name='get_food_logs')
    path('sendemailotp', SendOtpAPIView.as_view(), name='emailotp'),
    path('verifyemailotp', VerifyOtpAPIView.as_view(), name='verifyemailotp'),
    path('getfoodpredictions/<str:date_str>/', GetFoodPredictionsAPIView.as_view(), name='foodpredictions'),
    path('progress/calories', ProgressCaloriesAPIView.as_view(), name='progress_calories'),
    path('progress/macros', ProgressMacrosAPIView.as_view(), name='progress_macros'),
    path('progress/nutrients', ProgressNutrientsAPIView.as_view(), name='progress_nutrients'),
    path('progress/analytics', ProgressAnalyticsAPIView.as_view(), name='progress_analytics'),
    path('workouts', WorkoutListAPIView.as_view(), name='workout_list'),
    # Place static routes BEFORE dynamic slug routes to avoid 'summary' being treated as a slug
    path('workouts/summary', WorkoutSummaryAPIView.as_view(), name='workout_summary'),
    path('workouts/summary/', WorkoutSummaryAPIView.as_view(), name='workout_summary_slash'),
    path('workouts/<slug:slug>/complete', WorkoutCompleteAPIView.as_view(), name='workout_complete'),
    path('workouts/<slug:slug>/complete/', WorkoutCompleteAPIView.as_view(), name='workout_complete_slash'),
    path('workouts/<slug:slug>', WorkoutDetailAPIView.as_view(), name='workout_detail_no_slash'),
    path('workouts/<slug:slug>/', WorkoutDetailAPIView.as_view(), name='workout_detail'),
    path('manual-log/search', ManualLogSearchAPIView.as_view(), name='manual_log_search'),
    path('manual-log/predict', ManualLogPredictAPIView.as_view(), name='manual_log_predict'),
    path('manual-log/search/test', ManualLogSearchTestAPIView.as_view(), name='manual_log_search_test'),
    path('manual-log/save', ManualLogSaveAPIView.as_view(), name='manual_log_save'),
    path('manual-log/capture', ManualLogCaptureAPIView.as_view(), name='manual_log_capture'),
    path('foodlog/search', FoodLogSearchAPIView.as_view(), name='food_log_search'),
    path('user/diet-plans', DietPlanListCreateAPIView.as_view(), name='diet_plans_v2'),
    path('user/diet-plans/', DietPlanListCreateAPIView.as_view(), name='diet_plans_v2_slash'),
    path('diets', DietPlanListCreateAPIView.as_view(), name='diet_plans'),
    path('user/weight/dashboard', WeightDashboardAPIView.as_view(), name='weight_dashboard'),
    path('user/weight/dashboard/', WeightDashboardAPIView.as_view(), name='weight_dashboard_slash'),
    path('body/scan', BodyScanAPIView.as_view(), name='body_scan'),
    path('body/scan/', BodyScanAPIView.as_view(), name='body_scan_slash'),
    path('insights/generate', BodyScanInsightAPIView.as_view(), name='body_scan_insight'),
    path('insights/generate/', BodyScanInsightAPIView.as_view(), name='body_scan_insight_slash'),
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
