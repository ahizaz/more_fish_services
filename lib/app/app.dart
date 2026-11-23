import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/splash_binding.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/splash/controllers/splash_controller.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: SplashBinding(),
      home: Obx(() {
        final controller = Get.find<SplashController>();
        return controller.showSplash.value
            ? const SplashPage()
            : const HomePage();
      }),
    );
  }
}
