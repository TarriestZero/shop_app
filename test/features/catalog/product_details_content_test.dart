import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';
import 'package:shop_app/features/catalog/presentation/product_details/bloc/product_details_cubit.dart';
import 'package:shop_app/features/catalog/presentation/product_details/widgets/product_details_content.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';

void main() {
  for (final rating in [4.6, null]) {
    testWidgets('Карточка товара показывает рейтинг $rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: createAppLightTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ProductDetailsContent(
              state: ProductDetailsLoaded(
                CatalogProduct(
                  id: 1,
                  title: 'Товар',
                  priceInCents: 100,
                  category: 'Категория',
                  description: 'Описание',
                  rating: rating,
                  ratingCount: rating == null ? null : 120,
                ),
              ),
              onRefresh: () async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(
          rating == null
              ? 'Пока нет оценок'
              : 'Рейтинг: 4,6 из 5 · Оценок: 120',
        ),
        200,
      );
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
