import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final int statusCode;
  final T? data;
  final String? error;

  ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.error,
  });
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('admin_access_token');
  }

  void setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('admin_access_token', token);
    } else {
      await prefs.remove('admin_access_token');
    }
  }

  String? get token => _token;

  Map<String, String> _headers() {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  Future<ApiResponse<dynamic>> get(String url) async {
    try {
      final res = await http.get(Uri.parse(url), headers: _headers());
      return _processResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, statusCode: 500, error: 'Network connection failed: $e');
    }
  }

  Future<ApiResponse<dynamic>> post(String url, {dynamic body}) async {
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, statusCode: 500, error: 'Network error: $e');
    }
  }

  Future<ApiResponse<dynamic>> put(String url, {dynamic body}) async {
    try {
      final res = await http.put(
        Uri.parse(url),
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, statusCode: 500, error: 'Network error: $e');
    }
  }

  Future<ApiResponse<dynamic>> delete(String url) async {
    try {
      final res = await http.delete(Uri.parse(url), headers: _headers());
      return _processResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, statusCode: 500, error: 'Network error: $e');
    }
  }

  ApiResponse<dynamic> _processResponse(http.Response res) {
    dynamic decodedBody;
    try {
      if (res.body.isNotEmpty) {
        decodedBody = jsonDecode(res.body);
      }
    } catch (_) {
      decodedBody = res.body;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApiResponse(
        isSuccess: true,
        statusCode: res.statusCode,
        data: decodedBody,
      );
    } else {
      var errorMsg = 'An error occurred (${res.statusCode})';
      if (decodedBody is Map && decodedBody.containsKey('error')) {
        errorMsg = decodedBody['error'].toString();
      }
      return ApiResponse(
        isSuccess: false,
        statusCode: res.statusCode,
        data: decodedBody,
        error: errorMsg,
      );
    }
  }
}
