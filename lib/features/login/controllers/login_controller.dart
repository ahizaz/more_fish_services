import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/api/api.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isSubmitting = false;
  String? _loginError;

  bool get showPassword => _showPassword;
  bool get isSubmitting => _isSubmitting;
  String? get loginError => _loginError;

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_isSubmitting || !(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    _isSubmitting = true;
    _loginError = null;
    notifyListeners();
    try {
      final response = await Api.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _loginError =
            'Login failed. Please check your credentials and try again.';
        return false;
      }
      return true;
    } on FormatException catch (error) {
      debugPrint('Login response is invalid: $error');
      _loginError = 'Login failed. Invalid response from server.';
      return false;
    } on StateError catch (error) {
      debugPrint('Login token could not be saved: $error');
      _loginError = 'Login failed. Please try again.';
      return false;
    } on TimeoutException {
      _loginError = 'The login request timed out. Please try again.';
      return false;
    } on http.ClientException {
      _loginError = 'Could not connect to the server. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
