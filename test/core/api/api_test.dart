import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:more_fish/core/api/api.dart';

void main() {
  test('login posts the expected credentials to the auth endpoint', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, Api.loginUri);
      expect(request.headers['content-type'], 'application/json');
      expect(jsonDecode(request.body), {
        'usr_email': 'example@example.com',
        'password': 'test-password',
      });
      return http.Response('{}', 200);
    });

    final response = await Api.login(
      email: 'example@example.com',
      password: 'test-password',
      client: client,
    );

    debugPrint('Login response: ${response.statusCode} ${response.body}');
    expect(response.statusCode, 200);
    client.close();
  });
}
