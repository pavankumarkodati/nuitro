import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _userProfileKey = 'userProfile';

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _storage.write(
      key: _userProfileKey,
      value: jsonEncode(profile),
    );
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final raw = await _storage.read(key: _userProfileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // If decoding fails, treat as no profile and clear the corrupted entry.
      await _storage.delete(key: _userProfileKey);
    }
    return null;
  }

  static Future<void> clearUserProfile() async {
    await _storage.delete(key: _userProfileKey);
  }

  static Future<void> clearAll() async {
    await Future.wait([
      clearTokens(),
      clearUserProfile(),
    ]);
  }
}
