import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

void main() {
  testWidgets('Загрузка блокирует переданный обработчик нажатия', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Оформить',
            onPressed: () => pressed++,
            isLoading: true,
          ),
        ),
      ),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(pressed, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Конструктор иконки сохраняет tooltip и обрабатывает нажатие', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton.icon(
            tooltip: 'Корзина',
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => pressed++,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Корзина'));
    await tester.pump();
    expect(pressed, 1);
  });
}
