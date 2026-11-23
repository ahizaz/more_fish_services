import 'dart:async';

import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxBool showSplash = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer(const Duration(seconds: 3), () {
      showSplash.value = false;
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
