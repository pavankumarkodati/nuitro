import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/secure_storage.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isInitialized => _isInitialized;

  Future<void> ensureInitialized() async {
    if (_isInitialized) {
      return;
    }
    await loadUserFromStorage();
    _isInitialized = true;
  }

  Future<void> loadUserFromStorage() async {
    final stored = await TokenStorage.getUserProfile();
    if (stored == null) {
      return;
    }

    final model = _tryParseUser(stored);
    if (model == null) {
      await TokenStorage.clearUserProfile();
      return;
    }

    _user = model;
    notifyListeners();
  }

  Future<void> setUser(UserModel user) async {
    _user = user;
    await TokenStorage.saveUserProfile(user.toSanitizedJson());
    notifyListeners();
  }

  Future<void> setUserFromMap(Map<String, dynamic> json) async {
    final model = _tryParseUser(json);
    if (model == null) {
      return;
    }
    await setUser(model);
  }

  Future<void> logout() async {
    _user = null;
    await TokenStorage.clearAll();
    notifyListeners();
  }

  UserModel? _tryParseUser(Map<String, dynamic> json) {
    try {
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
