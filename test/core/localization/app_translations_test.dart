import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:more_fish/core/localization/app_translations.dart';

void main() {
  testWidgets('switching locale translates labels and formats digits/units', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: Builder(
          builder: (_) =>
              Column(children: [Text(appText('Home')), Text(appText('25 kg'))]),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('25 kg'), findsOneWidget);

    Get.updateLocale(const Locale('bn'));
    await tester.pumpAndSettle();

    expect(find.text('হোম'), findsOneWidget);
    expect(find.text('২৫ কেজি'), findsOneWidget);
  });
}
