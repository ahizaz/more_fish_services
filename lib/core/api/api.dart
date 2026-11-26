import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {
  Api._();

  static const String baseUrl = 'http://192.168.0.120:8000';
  static Uri get loginUri => Uri.parse('$baseUrl/auth/login/');

  static Future<http.Response> login({
    required String email,
    required String password,
    http.Client? client,
  }) {
    final request = client?.post ?? http.post;
    return request(
      loginUri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'usr_email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));
  }
}
