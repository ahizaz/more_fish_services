import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  Api._();

  static const String baseUrl = 'http://192.168.0.120:8000';
  static const String authorizationKey = 'Authorization';
  static Uri get loginUri => Uri.parse('$baseUrl/auth/login/');
  static Uri get farmsUri => Uri.parse('$baseUrl/fish_care/farms/');

  static Future<bool> hasSavedToken() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(authorizationKey);
    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    final removed = await preferences.remove(authorizationKey);
    if (!removed) {
      throw StateError('Could not remove the saved authorization token.');
    }
  }

  static Future<Map<String, String>> authorizationHeaders() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(authorizationKey);
    if (token == null || token.isEmpty) {
      throw StateError('No saved authorization token. Please log in again.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  static Future<http.Response> createFarm({
    required String name,
    required String location,
    http.Client? client,
  }) async {
    final request = client?.post ?? http.post;
    final response = await request(
      farmsUri,
      headers: await authorizationHeaders(),
      body: jsonEncode({'name': name, 'location': location}),
    ).timeout(const Duration(seconds: 15));
    return response;
  }

  static Future<http.Response> login({
    required String email,
    required String password,
    http.Client? client,
  }) async {
    final request = client?.post ?? http.post;
    final response = await request(
      loginUri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'usr_email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid login response.');
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Login response is missing data.');
      }
      final token = data['token'];
      if (token is! String || token.trim().isEmpty) {
        throw const FormatException('Login response is missing data.token.');
      }

      final sanitizedResponse = Map<String, dynamic>.from(decoded);
      sanitizedResponse['data'] = {...data, 'token': '[REDACTED]'};
      debugPrint(
        'Login API response: ${response.statusCode} '
        '${jsonEncode(sanitizedResponse)}',
      );

      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(authorizationKey, token.trim());
      if (!saved) {
        throw StateError('Could not save the authorization token.');
      }
    } else {
      debugPrint('Login API response: ${response.statusCode} ${response.body}');
    }
    return response;
  }
}
