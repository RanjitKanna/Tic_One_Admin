import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/admin_api_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    checkAuthSession();
  }

  Future<void> checkAuthSession() async {
    _isLoading = true;
    notifyListeners();

    await ApiClient().init();
    if (ApiClient().token != null) {
      final res = await _apiService.getMe();
      if (res.isSuccess && res.data != null) {
        _user = res.data;
        _errorMessage = null;
      } else {
        _user = null;
        ApiClient().setToken(null);
      }
    } else {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _apiService.login(email, password);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      if (res.data!['user'] != null) {
        _user = UserModel.fromJson(res.data!['user']);
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = res.error ?? 'Invalid email or password';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _apiService.logout();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
}
