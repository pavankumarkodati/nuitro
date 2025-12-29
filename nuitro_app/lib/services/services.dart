import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/models/user_profile.dart';
import 'package:nuitro/services/secure_storage.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_helper.dart';

class ApiServices {
  static String get baseUrl => ApiConfig.baseUrl;

  // 1. Signup API
  static Future<ApiResponse> signup(String email, String fullName,String mobileNumber,String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.signupEndpoint}");
    // Debug: request log (sanitized)
    debugPrint('[SIGNUP][REQ] POST ' + url.toString());
    debugPrint('[SIGNUP][REQ] body: ' + jsonEncode({
      'email': email,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'password': '***',
    }));
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "email": email,
          "full_name": fullName,
          "mobile_number": mobileNumber,
          "password": password
      }),
    );
    debugPrint('[SIGNUP][RES] status: ' + response.statusCode.toString());
    debugPrint('[SIGNUP][RES] body: ' + (response.body.length > 500 ? response.body.substring(0,500) + '…' : response.body));

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      data = null;
    }

    if (response.statusCode == 200) {
      final access = data?["access"];
      final refresh = data?["refresh"];
      if (access is String && refresh is String) {
        await TokenStorage.saveTokens(access, refresh);
      } else {
        debugPrint('[SIGNUP][RES] Missing tokens in response payload');
      }

      final message = (data?["message"] as String?) ?? "Sign up Successful. Please log in";
      return ApiResponse(status: true, message: message, data: data);
    }

    return _processResponse(response, successMessage: "Sign up Successful. Please log in");
  }

  // 2. Login
  static Future<ApiResponse> login(String email, String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}");
    debugPrint('[LOGIN][REQ] POST ${url.toString()}');
    debugPrint('[LOGIN][REQ] body: ' + jsonEncode({'email': email, 'password': '***'}));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    debugPrint('[LOGIN][RES] status: ${response.statusCode}');
    final preview = response.body.length > 500 ? '${response.body.substring(0, 500)}…' : response.body;
    debugPrint('[LOGIN][RES] body: $preview');

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (error) {
      debugPrint('[LOGIN][ERR] Failed to decode body: $error');
    }

    if (response.statusCode == 200 && data != null) {
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;
      if (access != null && refresh != null) {
        await TokenStorage.saveTokens(access, refresh);
      }
      final message = data['message']?.toString() ?? 'Login successful';
      return ApiResponse(status: true, message: message, data: data);
    }

    final message = data?['error']?.toString() ?? 'Login failed';
    return ApiResponse(status: false, message: message, data: data);
  }

  //
  // // 3. Nutrition Info API
  // static Future<Map<String, dynamic>?> getNutritionInfo(String token, String foodName) async {
  //   final url = Uri.parse("$baseUrl/api/nutritioninfo");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": token,
  //     },
  //     body: jsonEncode({"food": foodName}),
  //   );
  //   return _processResponse(response);
  // }
  //
  // 4. User Profile Info API
  static Future<ApiResponse> updateUserProfile(UserProfile profileData) async {

    return await ApiHelper.postWithAuth(
      ApiConfig.userProfileInfoEndpoint,profileData.toJson(),successMessage:"Profile Updated successfully");
  }

  static Future<ApiResponse> getFoodPredictions({DateTime? date}) async {
    final formattedDate = ApiConfig.formatDate(date ?? ApiConfig.localToday());
    return ApiHelper.getWithAuth(
      ApiConfig.foodPredictionsForDate(formattedDate),
      successMessage: "Fetched successfully",
    );
  }

  static Future<ApiResponse> getProgressAnalytics({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final endpoint = _composeProgressEndpoint(
      ApiConfig.progressAnalyticsEndpoint,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
    return ApiHelper.getWithAuth(
      endpoint,
      successMessage: "Progress analytics fetched successfully",
    );
  }

  static Future<ApiResponse> getProgressCalories({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final endpoint = _composeProgressEndpoint(
      ApiConfig.progressCaloriesEndpoint,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
    return ApiHelper.getWithAuth(
      endpoint,
      successMessage: "Progress calories fetched successfully",
    );
  }

  static Future<ApiResponse> getProgressMacros({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final endpoint = _composeProgressEndpoint(
      ApiConfig.progressMacrosEndpoint,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
    return ApiHelper.getWithAuth(
      endpoint,
      successMessage: "Progress macros fetched successfully",
    );
  }

  static Future<ApiResponse> getProgressNutrients({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final endpoint = _composeProgressEndpoint(
      ApiConfig.progressNutrientsEndpoint,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
    return ApiHelper.getWithAuth(
      endpoint,
      successMessage: "Progress nutrients fetched successfully",
    );
  }
  //
  // // 5. Food Log API
  // static Future<Map<String, dynamic>?> logFood(String token, Map<String, dynamic> logData) async {
  //   final url = Uri.parse("$baseUrl/api/foodlog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": token,
  //     },
  //     body: jsonEncode(logData),
  //   );
  //   return _processResponse(response);
  // }
  //
  // // 6. Get Food Log API
  // static Future<Map<String, dynamic>?> getFoodLog(String token) async {
  //   final url = Uri.parse("$baseUrl/api/getfoodlog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Authorization": token,
  //     },
  //   );
  //   return _processResponse(response);
  // }
  //
  // // 7. Delete Food Log API
  // static Future<Map<String, dynamic>?> deleteFoodLog(String token, String logId) async {
  //   final url = Uri.parse("$baseUrl/api/deletefoodlog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": token,
  //     },
  //     body: jsonEncode({"logId": logId}),
  //   );
  //   return _processResponse(response);
  // }
  //
  // // 8. Water Log API
  // static Future<Map<String, dynamic>?> logWater(String token, Map<String, dynamic> waterData) async {
  //   final url = Uri.parse("$baseUrl/api/waterlog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": token,
  //     },
  //     body: jsonEncode(waterData),
  //   );
  //   return _processResponse(response);
  // }
  //
  // // 9. Get Water Log API
  // static Future<Map<String, dynamic>?> getWaterLog(String token) async {
  //   final url = Uri.parse("$baseUrl/api/getwaterlog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Authorization": token,
  //     },
  //   );
  //   return _processResponse(response);
  // }
  //
  // // 10. Delete Water Log API
  // static Future<Map<String, dynamic>?> deleteWaterLog(String token, String logId) async {
  //   final url = Uri.parse("$baseUrl/api/deletewaterlog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": token,
  //     },
  //     body: jsonEncode({"logId": logId}),
  //   );
  //   return _processResponse(response);
  // }
  //
  // // 11. Step Counter Log API
  // static Future<Map<String, dynamic>?> logSteps(String token, Map<String, dynamic> stepData) async {
  //   final url = Uri.parse("$baseUrl/api/steplog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": token,
  //     },
  //     body: jsonEncode(stepData),
  //   );
  //   return _processResponse(response);
  // }
  //
  // // 12. Get Step Counter Log API
  // static Future<Map<String, dynamic>?> getStepLog(String token) async {
  //   final url = Uri.parse("$baseUrl/api/getsteplog");
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Authorization": token,
  //     },
  //   );
  //   return _processResponse(response);
  // }

  // 13. Send Email OTP
  static Future<ApiResponse> sendEmailOtp(String email) async {
    final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.sendEmailOtpEndpoint}");
    debugPrint('[EMAIL OTP][REQ] POST ' + url.toString());
    debugPrint('[EMAIL OTP][REQ] body: ' + jsonEncode({'email': email}));
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    debugPrint('[EMAIL OTP][RES] status: ' + response.statusCode.toString());
    debugPrint('[EMAIL OTP][RES] body: ' + (response.body.length > 500 ? response.body.substring(0,500) + '…' : response.body));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: true,
          message: data is Map<String, dynamic>
              ? (data["message"] as String? ?? "OTP generated")
              : "OTP generated",
          data: data,
        );
      } catch (_) {
        return ApiResponse(status: true, message: "OTP generated", data: null);
      }
    }

    return _processResponse(
      response,
      failedMessage: "Failed to generate OTP",
    );
  }

  static Future<ApiResponse> sendMobileOtp(String mobile) async {
    final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.mobileOtpEndpoint}");
    debugPrint('[MOBILE OTP][REQ] POST ' + url.toString());
    debugPrint('[MOBILE OTP][REQ] body: ' + jsonEncode({'mobile': mobile}));
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile}),
    );
    debugPrint('[MOBILE OTP][RES] status: ' + response.statusCode.toString());
    debugPrint('[MOBILE OTP][RES] body: ' + (response.body.length > 500 ? response.body.substring(0,500) + '…' : response.body));
    return _processResponse(response, successMessage: "Mobile OTP sent");
  }

  static Future<ApiResponse> verifyMobileOtp(String mobile, String otp) async {
    final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.mobileOtpEndpoint}");
    debugPrint('[VERIFY MOBILE OTP][REQ] POST ' + url.toString());
    debugPrint('[VERIFY MOBILE OTP][REQ] body: ' + jsonEncode({'mobile': mobile, 'otp': '******'}));
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile, "otp": otp}),
    );
    debugPrint('[VERIFY MOBILE OTP][RES] status: ' + response.statusCode.toString());
    debugPrint('[VERIFY MOBILE OTP][RES] body: ' + (response.body.length > 500 ? response.body.substring(0,500) + '…' : response.body));
    return _processResponse(response, successMessage: "Mobile OTP verified");
  }

  // 14. Verify Email OTP
  static Future<ApiResponse> verifyEmailOtp(String email, String otp) async {
    print("===============================");
    print(email);
    print(otp);
    final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.verifyEmailOtpEndpoint}");
    debugPrint('[VERIFY EMAIL OTP][REQ] POST ' + url.toString());
    debugPrint('[VERIFY EMAIL OTP][REQ] body: ' + jsonEncode({'email': email, 'otp': '******'}));
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"email": email, "otp": otp}),
    );
    debugPrint('[VERIFY EMAIL OTP][RES] status: ' + response.statusCode.toString());
    debugPrint('[VERIFY EMAIL OTP][RES] body: ' + (response.body.length > 500 ? response.body.substring(0,500) + '…' : response.body));
    return _processResponse(response);
  }

  static ApiResponse _processResponse(
      http.Response response, {
        String successMessage = "Success",
        String failedMessage = "Something went wrong",
      }) {
    dynamic responseData;


      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        responseData = null;
        return ApiResponse(
          status: false,
          message: failedMessage,
          data: null,
        );
      }
    if (response.statusCode == 200) {
      return ApiResponse(
        status: true,
        message: successMessage,
        data: responseData,
      );
    } else {
      String resolvedMessage = failedMessage;
      dynamic resolvedData;
      if (responseData is Map<String, dynamic>) {
        final messageValue = responseData["message"] ?? responseData["error"];
        if (messageValue is String && messageValue.isNotEmpty) {
          resolvedMessage = messageValue;
        }
        resolvedData = responseData["data"] ?? responseData;
      }
      return ApiResponse(
        status: false,
        message: resolvedMessage,
        data: resolvedData,
      );
    }
  }








  static Future<ApiResponse> uploadImage(XFile imageFile) async {
    try {
      return await ApiHelper.postMultipartWithAuth(
          ApiConfig.nutritionInfoEndpoint,imageFile,successMessage:"Photo uploaded successfully");
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }

  static Future<ApiResponse> manualSearchFoods(String query) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.manualLogSearchEndpoint,
        {"query": query},
        successMessage: "Manual search completed",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> manualPredictFood(String query) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.manualLogPredictEndpoint,
        {"query": query},
        successMessage: "Manual prediction completed",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> voicePredict(String transcript) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.manualLogPredictEndpoint,
        {"query": transcript},
        successMessage: "Voice prediction completed",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> manualSaveEntry(Map<String, dynamic> payload) async {
    try {
      // Ensure local date is explicitly included to avoid server-side UTC inference
      final Map<String, dynamic> payloadWithDate = {
        ...payload,
        'date': payload['date'] ?? ApiConfig.formattedLocalToday(),
      };

      return await ApiHelper.postWithAuth(
        ApiConfig.manualLogSaveEndpoint,
        payloadWithDate,
        successMessage: "Manual entry saved",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> manualCapture(Map<String, dynamic> payload) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.manualLogCaptureEndpoint,
        payload,
        successMessage: "Manual capture completed",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> voiceCapture(Map<String, dynamic> payload) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.manualLogCaptureEndpoint,
        payload,
        successMessage: "Voice capture completed",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> logsSearch({String? query, DateTime? date}) async {
    final params = <String>[];
    if (date != null) {
      params.add('date=${_formatDate(date)}');
    }
    final trimmed = query?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      params.add('q=${Uri.encodeComponent(trimmed)}');
    }
    final basePath = ApiConfig.foodLogSearchEndpoint;
    final searchPath = params.isEmpty
        ? basePath
        : "$basePath?${params.join('&')}";

    try {
      return await ApiHelper.getWithAuth(
        searchPath,
        successMessage: "Food logs fetched successfully",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> logsCapture(Map<String, dynamic> payload) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.foodLogCaptureEndpoint,
        payload,
        successMessage: "Food capture completed",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> logFood(Map<String,dynamic> scanResult) async {
    try {
      // Inject date into payload (prefer inside data if present) to align with local day
      final Map<String, dynamic> updated = Map<String, dynamic>.from(scanResult);
      final dynamic dataLayer = updated['data'];
      if (dataLayer is Map<String, dynamic>) {
        final Map<String, dynamic> inner = Map<String, dynamic>.from(dataLayer);
        inner['date'] = inner['date'] ?? ApiConfig.formattedLocalToday();
        updated['data'] = inner;
      } else {
        updated['date'] = updated['date'] ?? ApiConfig.formattedLocalToday();
      }

      return await ApiHelper.postWithAuth(
          ApiConfig.foodLogEndpoint,updated,successMessage:"Food logged successfully");
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }










  static Future<ApiResponse> uploadBarcodeImage(XFile imageFile) async {
    try {
      return await ApiHelper.postMultipartWithAuth(
          ApiConfig.barcodeScanEndpoint,imageFile,successMessage:"Barcode Photo uploaded successfully");
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }




  static Future<ApiResponse> getFoodLog({DateTime? date}) async {
    try {
      final formattedDate = ApiConfig.formatDate(date ?? ApiConfig.localToday());
      return await ApiHelper.getWithAuth(
        ApiConfig.foodLogForDate(formattedDate),
        successMessage: "Food log fetched successfully",
      );
    } catch (e) {
      throw Exception("Error fetching food log: $e");
    }
  }

  static Future<ApiResponse> getWaterLog({DateTime? date}) async {
    try {
      final formattedDate = ApiConfig.formatDate(date ?? ApiConfig.localToday());
      return await ApiHelper.getWithAuth(
        ApiConfig.waterLogForDate(formattedDate),
        successMessage: "Water log fetched successfully",
      );
    } catch (e) {
      throw Exception("Error fetching water log: $e");
    }
  }

  static Future<ApiResponse> logWater({required Map<String, dynamic> payload}) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.waterLogEndpoint,
        payload,
        successMessage: "Water logged successfully",
      );
    } catch (e) {
      throw Exception("Error logging water: $e");
    }
  }

  static Future<ApiResponse> updateWellness({
    required DateTime date,
    required String mood,
    required String question,
    required List<String> options,
  }) async {
    try {
      final payload = {
        'date': _formatDate(date),
        'mood': mood,
        'question': question,
        'options': options,
      };
      return await ApiHelper.postWithAuth(
        ApiConfig.updateWellnessEndpoint,
        payload,
        successMessage: "Wellness updated",
      );
    } catch (e) {
      throw Exception("Error updating wellness: $e");
    }
  }

  // Diet plans: add and fetch for the authenticated user
  static Future<ApiResponse> addDietPlan({
    required Map<String, dynamic> payload,
  }) async {
    try {
      return await ApiHelper.postWithAuth(
        ApiConfig.dietPlansEndpoint,
        payload,
        successMessage: "Diet added to your plans",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> getMyDiets() async {
    try {
      return await ApiHelper.getWithAuth(
        ApiConfig.dietPlansEndpoint,
        successMessage: "Diets fetched successfully",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> getWeightDashboard() async {
    try {
      return await ApiHelper.getWithAuth(
        ApiConfig.weightDashboardEndpoint,
        successMessage: "Weight dashboard fetched successfully",
      );
    } catch (e) {
      return ApiResponse(status: false, message: e.toString(), data: null);
    }
  }

  static String _formatDate(DateTime date) {
    return ApiConfig.formatDate(date);
  }

  static String _composeProgressEndpoint(
    String basePath, {
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, String>? extra,
  }) {
    final params = <String, String>{
      'period': period,
      if (startDate != null) 'start_date': _formatDate(startDate),
      if (endDate != null) 'end_date': _formatDate(endDate),
      ...?extra,
    };

    params.removeWhere((key, value) => value.trim().isEmpty);
    if (params.isEmpty) {
      return basePath;
    }

    final query = params.entries
        .map((entry) =>
            "${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}")
        .join('&');
    return "$basePath?$query";
  }
}


