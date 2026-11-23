import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

void main() {
  for (final (type, value, required, error) in [
    (AppTextFieldType.name, '   ', true, 'Обязательное поле'),
    (AppTextFieldType.email, 'wrong@', true, 'Введите корректный email'),
    (
      AppTextFieldType.email,
      'name@example..com',
      true,
      'Введите корректный email',
    ),
    (AppTextFieldType.email, ' anna+order@example.co.uk ', true, null),
    (AppTextFieldType.email, "o'connor@example.com", true, null),
    for (final email in [
      'a,b@example.com',
      'a:b@example.com',
      'a;b@example.com',
      'a<b@example.com',
      'a"b@example.com',
      '.anna@example.com',
      'anna.@example.com',
      'anna..order@example.com',
    ])
      (AppTextFieldType.email, email, true, 'Введите корректный email'),
    (AppTextFieldType.email, '', false, null),
    (AppTextFieldType.phone, '123456789', true, 'Введите не менее 10 цифр'),
    (AppTextFieldType.phone, '+7 (999) 123-45-67', true, null),
    (AppTextFieldType.address, '   ', true, 'Обязательное поле'),
    (AppTextFieldType.address, 'Москва, ул. Мира, 10', true, null),
  ]) {
    testWidgets('Поле $type проверяет значение "$value"', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: createAppLightTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: AppTextField(
                  label: 'Поле',
                  controller: controller,
                  type: type,
                  isRequired: required,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), value);
      expect(formKey.currentState!.validate(), error == null);
      await tester.pump();
      if (error != null) expect(find.text(error), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      if (type == AppTextFieldType.phone) {
        expect(field.keyboardType, TextInputType.phone);
      }
      if (type == AppTextFieldType.email) {
        expect(field.keyboardType, TextInputType.emailAddress);
      }
    });
  }
}
