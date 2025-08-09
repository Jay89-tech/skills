// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Check if user is already logged in
    final token = _prefs?.getString(AppConstants.userTokenKey);
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      final user = response.data['user'];

      // Store token and user data
      await _prefs?.setString(AppConstants.userTokenKey, token);
      await _prefs?.setString(AppConstants.userDataKey, json.encode(user));

      // Set token for API service
      _apiService.setAuthToken(token);

      return {
        'success': true,
        'user': user,
        'token': token,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('/auth/register', data: userData);

      final token = response.data['token'];
      final user = response.data['user'];

      // Store token and user data
      await _prefs?.setString(AppConstants.userTokenKey, token);
      await _prefs?.setString(AppConstants.userDataKey, json.encode(user));

      // Set token for API service
      _apiService.setAuthToken(token);

      return {
        'success': true,
        'user': user,
        'token': token,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      print('Logout API call failed: $e');
    }

    // Clear stored data
    await _prefs?.remove(AppConstants.userTokenKey);
    await _prefs?.remove(AppConstants.userDataKey);
  }

  Future<bool> isLoggedIn() async {
    final token = _prefs?.getString(AppConstants.userTokenKey);
    return token != null;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userJson = _prefs?.getString(AppConstants.userDataKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  Future<String?> getToken() async {
    return _prefs?.getString(AppConstants.userTokenKey);
  }

  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.post('/auth/refresh');
      final newToken = response.data['token'];

      // Update stored token
      await _prefs?.setString(AppConstants.userTokenKey, newToken);
      _apiService.setAuthToken(newToken);

      return true;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }
}
