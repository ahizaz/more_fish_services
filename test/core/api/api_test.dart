import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:more_fish/core/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('login posts the expected credentials to the auth endpoint', () async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, Api.loginUri);
      expect(request.headers['content-type'], 'application/json');
      expect(jsonDecode(request.body), {
        'usr_email': 'example@example.com',
        'password': 'test-password',
      });
      return http.Response(
        jsonEncode({
          'success': true,
          'status_code': 200,
          'message': 'User logged in successfully',
          'data': {'token': 'test-auth-token'},
        }),
        200,
      );
    });

    final response = await Api.login(
      email: 'example@example.com',
      password: 'test-password',
      client: client,
    );

    expect(response.statusCode, 200);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('Authorization'), 'test-auth-token');
    client.close();
  });

  test('createFarm posts the expected payload to the farms endpoint', () async {
    SharedPreferences.setMockInitialValues({
      'Authorization': 'test-auth-token',
    });
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, Api.farmsUri);
      expect(request.headers['content-type'], 'application/json');
      expect(request.headers['authorization'], 'Token test-auth-token');
      expect(jsonDecode(request.body), {'name': 'izaz', 'location': 'mirpur'});
      return http.Response('{}', 201);
    });

    final response = await Api.createFarm(
      name: 'izaz',
      location: 'mirpur',
      client: client,
    );

    expect(response.statusCode, 201);
    client.close();
  });

  test('saved token remains available until logout removes it', () async {
    SharedPreferences.setMockInitialValues({
      Api.authorizationKey: 'test-auth-token',
    });

    expect(await Api.hasSavedToken(), isTrue);

    await Api.logout();

    expect(await Api.hasSavedToken(), isFalse);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(Api.authorizationKey), isNull);
  });
}
