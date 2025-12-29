import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/services/secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiHelper {
  static String get baseUrl => ApiConfig.baseUrl;

  static Map<String, String> _buildHeaders({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<bool> _tryRefreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final url = Uri.parse("$baseUrl/api/token/refresh/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
      );

      Map<String, dynamic>? responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        responseData = null;
      }

      if (response.statusCode == 200 && responseData != null) {
        final newAccess = responseData["access"] as String?;
        final newRefresh = responseData["refresh"] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          if (newRefresh != null && newRefresh.isNotEmpty) {
            await TokenStorage.saveTokens(newAccess, newRefresh);
          } else {
            await TokenStorage.saveAccessToken(newAccess);
          }
          return true;
        }
      }
    } catch (_) {
      // Swallow and report failure; callers will treat as unauthenticated.
    }
    return false;
  }

  static bool _isTokenExpired(String token, {Duration buffer = Duration.zero}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }
      final normalized = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalized);
      final payload = jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) {
        return true;
      }
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
      final threshold = DateTime.now().toUtc().add(buffer);
      return expiry.isBefore(threshold);
    } catch (_) {
      return true;
    }
  }

  static Future<bool> ensureFreshAccessToken({Duration buffer = const Duration(minutes: 1)}) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return await _tryRefreshAccessToken();
    }
    if (_isTokenExpired(token, buffer: buffer)) {
      return await _tryRefreshAccessToken();
    }
    return true;
  }

  static Future<bool> forceRefreshAccessToken() async {
    return await _tryRefreshAccessToken();
  }

  static String _resolveErrorMessage(dynamic responseData, {String fallback = "Something went wrong"}) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData["message"] ?? responseData["error"] ?? responseData["detail"];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }
    return fallback;
  }

  static Future<ApiResponse> postWithAuth(String endpoint,
      Map<String, dynamic>? body,{String successMessage="success"}) async {
    // Proactively ensure token is fresh
    await ensureFreshAccessToken();
    String? token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$baseUrl$endpoint");

    print(url);
    print(token);
    print(body);

    // If still no token, try a forced refresh once, then re-read
    if (token == null || token.isEmpty) {
      final forced = await forceRefreshAccessToken();
      if (forced) {
        token = await TokenStorage.getAccessToken();
      }
      if (token == null || token.isEmpty) {
        return ApiResponse(status: false, message: "Unauthorized", data: null);
      }
    }

    var response = await http.post(
      url,
      headers: _buildHeaders(token: token),
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshAccessToken();
      if (refreshed) {
        token = await TokenStorage.getAccessToken();
        response = await http.post(
          url,
          headers: _buildHeaders(token: token),
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    var responseData;
    try {
      responseData = jsonDecode(response.body);
      print(response.statusCode.toString());
    } catch (e) {
      final snippet = response.body.toString();
      final shortBody = snippet.length > 300 ? snippet.substring(0, 300) + '…' : snippet;
      return ApiResponse(
        status: false,
        message: "Failed to parse server response (status ${response.statusCode}). Body: ${shortBody}",
        data: null,
      );
    }
    if (response.statusCode == 401) {
      return ApiResponse(
        status: false,
        message: responseData["error"],
        data: null,
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
    return ApiResponse(
    status: true,
    message: successMessage,
    data: responseData,
    );
    } else {
    return ApiResponse(
      status: false,
      message: _resolveErrorMessage(responseData),
      data: responseData,
    );
    }
    }


  static Future<ApiResponse> getWithAuth(String endpoint,{String successMessage="success"}) async {
    // Proactively ensure token is fresh
    await ensureFreshAccessToken();
    String? token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$baseUrl$endpoint");

    print(url);
    print(token);

    // If still no token, try a forced refresh once, then re-read
    if (token == null || token.isEmpty) {
      final forced = await forceRefreshAccessToken();
      if (forced) {
        token = await TokenStorage.getAccessToken();
      }
      if (token == null || token.isEmpty) {
        return ApiResponse(status: false, message: "Unauthorized", data: null);
      }
    }

    var response = await http.get(
      url,
      headers: _buildHeaders(token: token),
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshAccessToken();
      if (refreshed) {
        token = await TokenStorage.getAccessToken();
        print("Refreshed access token: $token");
        response = await http.get(
          url,
          headers: _buildHeaders(token: token),
        );
      }
    }

    var responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      final snippet = response.body.toString();
      final shortBody = snippet.length > 300 ? snippet.substring(0, 300) + '…' : snippet;
      return ApiResponse(
        status: false,
        message: "Failed to parse server response (status ${response.statusCode}). Body: ${shortBody}",
        data: null,
      );
    }
    if (response.statusCode == 401) {
      return ApiResponse(
        status: false,
        message: responseData["error"],
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
      return ApiResponse(
        status: false,
        message: _resolveErrorMessage(responseData),
        data: responseData,
      );
    }
  }





  static Future<ApiResponse> postMultipartWithAuth(
      String endpoint,
      XFile file, {
        String fieldName = "image", // default field name used by your API
        String successMessage = "success",
      }) async {
    String? token = await TokenStorage.getAccessToken();
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      var request = http.MultipartRequest("POST", url);

      // headers
      if (token != null) {
        request.headers["Authorization"] = "Bearer $token";
      }
      print('heoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo');
      print(request.headers);


      // attach image
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      // send
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      var responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        final snippet = response.body.toString();
        final shortBody = snippet.length > 300 ? snippet.substring(0, 300) + '…' : snippet;
        return ApiResponse(
          status: false,
          message: "Failed to parse server response (status ${response.statusCode}). Body: ${shortBody}",
          data: null,
        );
      }

      if (response.statusCode == 401) {
        final refreshed = await _tryRefreshAccessToken();
        if (refreshed) {
          return await postMultipartWithAuth(
            endpoint,
            file,
            fieldName: fieldName,
            successMessage: successMessage,
          );
        }
        return ApiResponse(
          status: false,
          message: responseData["error"] ?? "Unauthorized",
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
        return ApiResponse(
          status: false,
          message: _resolveErrorMessage(responseData),
          data: responseData,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: false,
        message: "Exception: $e",
        data: null,
      );
    }
  }







}