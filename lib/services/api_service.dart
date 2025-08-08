import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late http.Client _client;
  String? _authToken;

  void initialize() {
    _client = http.Client();
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<ApiResponse> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.get(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.post(
        url,
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.put(
        url,
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client.delete(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        data: data,
        statusCode: response.statusCode,
        message: data['message'] ?? 'Success',
      );
    } else {
      throw ApiException(
        data['message'] ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiResponse {
  final dynamic data;
  final int statusCode;
  final String message;

  ApiResponse({
    required this.data,
    required this.statusCode,
    required this.message,
  });
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}