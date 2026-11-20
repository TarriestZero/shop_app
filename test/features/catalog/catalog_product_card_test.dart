import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';
import 'package:shop_app/features/catalog/presentation/catalog/widgets/catalog_product_card.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

import '../../support/cart_test_support.dart';

void main() {
  for (final scale in [1.0, 1.5]) {
    testWidgets(
      'Product layout stays fixed when cart membership changes at scale $scale',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final bloc = CartNotifierBloc(
          createCartRepository(MemoryCartPreferences()),
        )..add(const CartStarted());
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await bloc.close();
        });

        await tester.pumpWidget(
          BlocProvider.value(
            value: bloc,
            child: MaterialApp(
              theme: createAppLightTheme(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 180,
                    height: 360,
                    child: CatalogProductCard(
                      product: const CatalogProduct(
                        id: 1,
                        title: 'Название товара',
                        priceInCents: 1000,
                        category: 'Категория',
                        description: '',
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final titleRect = tester.getRect(find.text('Название товара'));
        final categoryRect = tester.getRect(find.text('Категория'));
        final imageRect = tester.getRect(find.byType(AppProductImage));
        void expectStableLayout() {
          expect(tester.getRect(find.text('Название товара')), titleRect);
          expect(tester.getRect(find.text('Категория')), categoryRect);
          expect(tester.getRect(find.byType(AppProductImage)), imageRect);
          expect(tester.takeException(), isNull);
        }

        await tester.tap(find.byTooltip('В корзину'));
        await tester.pumpAndSettle();
        expect(bloc.state.quantityFor(1), 1);
        expectStableLayout();

        await tester.tap(find.byTooltip('Увеличить количество'));
        await tester.pumpAndSettle();
        expect(bloc.state.quantityFor(1), 2);
        expectStableLayout();

        final removal = bloc.removeProduct(1);
        await tester.pumpAndSettle();
        expect(await removal, isTrue);
        expectStableLayout();
      },
    );
  }
}
