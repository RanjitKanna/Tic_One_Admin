import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/admin_api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();
  
  DashboardStatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  DashboardStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _apiService.getDashboardStats();
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _stats = res.data;
    } else {
      _error = res.error ?? 'Failed to load dashboard statistics';
    }
    notifyListeners();
  }
}
