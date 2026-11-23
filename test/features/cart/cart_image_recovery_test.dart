import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/network/network_connection_service.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';
import 'package:shop_app/features/cart/presentation/cart/screen/cart_screen.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';

import '../../support/cart_test_support.dart';
import '../../support/catalog_test_support.dart';
import '../../support/image_test_support.dart';
import '../../support/network_test_support.dart';

void main() {
  testWidgets('Фото в открытой корзине появляются после восстановления сети', (
    tester,
  ) async {
    try {
      final app = await _pumpCart(tester, failImages: true);
      app.connections.add(false);
      await tester.pumpAndSettle();
      expect(app.images.requests, 1);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      final cartState = app.cart.state;
      final writes = app.preferences.writes;

      app.images.failRequests = false;
      app.connections.add(true);
      await tester.pumpAndSettle();
      await waitForDecodedImage(tester);
      expect(find.byIcon(Icons.image_outlined), findsNothing);
      expect(app.images.requests, 2);
      expect(app.cart.state, same(cartState));
      expect(app.preferences.writes, writes);
      expect(tester.takeException(), isNull);
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });

  testWidgets('Восстановление сети сохраняет уже загруженное фото корзины', (
    tester,
  ) async {
    try {
      final app = await _pumpCart(tester, failImages: false);
      app.connections.add(true);
      await tester.pumpAndSettle();
      final image = await waitForDecodedImage(tester);
      expect(app.images.requests, 1);

      app.connections.add(false);
      await tester.pumpAndSettle();
      app.connections.add(true);
      await tester.pumpAndSettle();
      expect(await waitForDecodedImage(tester), same(image));
      expect(app.images.requests, 1);
      expect(tester.takeException(), isNull);
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });
}

Future<
  ({
    StreamController<bool> connections,
    TestImageClient images,
    CartNotifierBloc cart,
    MemoryCartPreferences preferences,
  })
>
_pumpCart(WidgetTester tester, {required bool failImages}) async {
  final bytes = (await tester.runAsync(
    () => createTestPng(const Size(80, 40)),
  ))!;
  final images = TestImageClient(bytes)..failRequests = failImages;
  debugNetworkImageHttpClientProvider = () => images;
  final connections = StreamController<bool>.broadcast();
  final preferences = MemoryCartPreferences();
  final cartRepository = createCartRepository(preferences);
  await cartRepository.add(
    const CartItem(
      productId: 1,
      title: 'Товар с фото',
      priceInCents: 1000,
      quantity: 2,
      imageUrl: 'https://example.test/cart-product.png',
    ),
  );
  final cart = CartNotifierBloc(cartRepository)..add(const CartStarted());
  final catalog = CatalogRepository(
    CatalogTestClient(),
    connectionChanges: connections.stream,
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await cart.close();
    await catalog.close();
    await connections.close();
    debugNetworkImageHttpClientProvider = null;
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CatalogRepository>.value(value: catalog),
        RepositoryProvider<NetworkConnectionService>.value(
          value: TestNetworkConnectionService(connections.stream),
        ),
      ],
      child: BlocProvider.value(
        value: cart,
        child: MaterialApp(
          theme: createAppLightTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => const CartScreen().wrappedRoute(context),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (
    connections: connections,
    images: images,
    cart: cart,
    preferences: preferences,
  );
}
