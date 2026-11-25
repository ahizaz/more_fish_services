import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isSubmitting = false;

  bool get showPassword => _showPassword;
  bool get isSubmitting => _isSubmitting;

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_isSubmitting || !(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    _isSubmitting = true;
    notifyListeners();
    try {
      // Replace this local pass-through with the authentication API call.
      return true;
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
