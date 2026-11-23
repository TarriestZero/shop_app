import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/app/shop_app.dart';
import 'package:shop_app/core/network/network_connection_service.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/presentation/cart/widgets/cart_item_card.dart';
import 'package:shop_app/features/cart/presentation/widgets/cart_product_action.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

import '../../support/cart_test_support.dart';
import '../../support/network_test_support.dart';

void main() {
  testWidgets(
    'Без сети переход к оформлению недоступен, корзину можно менять',
    (tester) async {
      final connections = StreamController<bool>.broadcast();
      addTearDown(connections.close);
      final preferences = MemoryCartPreferences();
      await createCartRepository(preferences).add(cartProduct);
      final cart = await _pumpApp(
        tester,
        preferences,
        connectionChanges: connections.stream,
      );
      await _openCart(tester);
      connections.add(false);
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, 'К оформлению');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(
        find.text('Для оформления заказа подключитесь к интернету.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Увеличить количество'));
      await tester.pumpAndSettle();
      expect(cart.state.quantityFor(1), 2);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      connections.add(true);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      expect(
        find.text('Для оформления заказа подключитесь к интернету.'),
        findsNothing,
      );
    },
  );

  testWidgets('Кнопка пустой корзины открывает вкладку каталога', (
    tester,
  ) async {
    await _pumpApp(tester, MemoryCartPreferences());
    await _openCart(tester);
    expect(find.text('Корзина пуста'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Перейти в каталог'));
    await tester.pumpAndSettle();
    expect(find.byType(CartProductAction), findsOneWidget);
    expect(
      tester
          .widget<AppNavigationBar>(find.byType(AppNavigationBar))
          .selectedIndex,
      0,
    );
  });

  testWidgets('Catalog, cart and tab counter share the same notifier', (
    tester,
  ) async {
    final preferences = MemoryCartPreferences();
    final bloc = await _pumpApp(tester, preferences);
    await tester.tap(find.byTooltip('В корзину'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Увеличить количество'));
    await tester.tap(find.byTooltip('Увеличить количество'));
    await tester.pumpAndSettle();
    expect(bloc.state.quantityFor(1), 3);

    await _openCart(tester);
    expect(find.byType(CartItemCard), findsOneWidget);
    expect(find.text('Артикул: 1'), findsOneWidget);
    expect(
      tester
          .widget<AppQuantityStepper>(find.byType(AppQuantityStepper))
          .quantity,
      3,
    );
    await tester.tap(find.byTooltip('Уменьшить количество'));
    await tester.pumpAndSettle();
    expect(bloc.state.totalInCents, 44950);

    await tester.tap(_destination('Каталог'));
    await tester.pumpAndSettle();
    expect(find.byType(CartProductAction), findsOneWidget);
    expect(
      tester
          .widget<AppQuantityStepper>(find.byType(AppQuantityStepper))
          .quantity,
      2,
    );
    expect(await createCartRepository(preferences).load(), [
      cartProduct.withQuantity(2),
    ]);
  });

  testWidgets('Swiping removes the full group and updates catalog presence', (
    tester,
  ) async {
    final preferences = MemoryCartPreferences();
    await createCartRepository(preferences).add(cartProduct.withQuantity(5));
    final bloc = await _pumpApp(tester, preferences);
    await _openCart(tester);
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Корзина пуста'), findsOneWidget);
    expect(bloc.state.totalQuantity, 0);
    expect(await createCartRepository(preferences).load(), isEmpty);
    await tester.tap(_destination('Каталог'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('В корзину'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A failed swipe keeps the group and shows a localized error', (
    tester,
  ) async {
    final preferences = MemoryCartPreferences();
    await createCartRepository(preferences).add(cartProduct.withQuantity(5));
    final bloc = await _pumpApp(tester, preferences);
    await _openCart(tester);
    preferences.failWrites = true;
    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.byType(CartItemCard), findsOneWidget);
    expect(bloc.state.quantityFor(1), 5);
    expect(
      find.text('Не удалось сохранить данные на устройстве'),
      findsOneWidget,
    );
    expect(await createCartRepository(preferences).load(), [
      cartProduct.withQuantity(5),
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cart cards fit a narrow screen with larger text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 780));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(() async {
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await tester.binding.setSurfaceSize(null);
    });
    final preferences = MemoryCartPreferences();
    await createCartRepository(preferences).add(cartProduct.withQuantity(21));
    await _pumpApp(tester, preferences);
    await _openCart(tester);
    expect(find.byType(CartItemCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _destination(String label) => find.descendant(
  of: find.byType(AppNavigationBar),
  matching: find.text(label),
);

Future<void> _openCart(WidgetTester tester) async {
  await tester.tap(_destination('Корзина'));
  await tester.pumpAndSettle();
}

Future<CartNotifierBloc> _pumpApp(
  WidgetTester tester,
  MemoryCartPreferences preferences, {
  Stream<bool>? connectionChanges,
}) async {
  final bloc = CartNotifierBloc(createCartRepository(preferences))
    ..add(const CartStarted());
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await bloc.close();
  });
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CatalogRepository>.value(
          value: _CatalogRepository(),
        ),
        RepositoryProvider<NetworkConnectionService>.value(
          value: TestNetworkConnectionService(connectionChanges),
        ),
      ],
      child: BlocProvider.value(value: bloc, child: const ShopApp()),
    ),
  );
  await tester.pumpAndSettle();
  return bloc;
}

class _CatalogRepository extends Fake implements CatalogRepository {
  @override
  bool get isOffline => false;

  @override
  Stream<bool> get offlineChanges => const Stream.empty();

  @override
  Stream<List<CatalogProduct>> get changes => const Stream.empty();

  @override
  Future<List<CatalogProduct>?> getCachedCatalog() async => null;

  @override
  Future<List<CatalogProduct>> loadCatalog() async => [
    CatalogProduct(
      id: cartProduct.productId,
      title: cartProduct.title,
      priceInCents: cartProduct.priceInCents,
      category: cartProduct.category,
      description: '',
    ),
  ];
}
