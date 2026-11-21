import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/app/shop_app.dart';
import 'package:shop_app/core/network/network_connection_service.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';

import '../../support/cart_test_support.dart';
import '../../support/catalog_test_support.dart';
import '../../support/network_test_support.dart';

const _timeoutMessage = 'Истекло время ожидания ответа. Попробуйте ещё раз.';

void main() {
  testWidgets(
    'Каталог показывает загрузку, отдельный таймаут и успех после повтора',
    (tester) async {
      final pending = Completer<List<ProductDto>>();
      final client = CatalogTestClient()..fetch = () => pending.future;
      await _pumpCatalog(tester, client: client);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.completeError(_timeout());
      await tester.pumpAndSettle();
      expect(find.text(_timeoutMessage), findsOneWidget);
      expect(find.text('Нет соединения'), findsNothing);
      expect(
        find.text('Подключитесь к интернету, чтобы загрузить каталог.'),
        findsNothing,
      );

      client.fetch = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Повторить'));
      await tester.pumpAndSettle();
      expect(find.text(detailsProduct.title!), findsOneWidget);
      expect(find.text(_timeoutMessage), findsNothing);
      expect(client.requests, 2);
    },
  );

  testWidgets('Таймаут обновления сохраняет кеш и показывает своё сообщение', (
    tester,
  ) async {
    final client = CatalogTestClient()..error = _timeout();
    await _pumpCatalog(
      tester,
      client: client,
      cache: CatalogTestCache()..products = [detailsProduct],
    );
    await tester.pumpAndSettle();
    expect(find.text(detailsProduct.title!), findsOneWidget);
    expect(find.text(_timeoutMessage), findsOneWidget);
    expect(find.text('Нет соединения'), findsNothing);
  });

  testWidgets('Смена сети после успешной загрузки обновляет открытый каталог', (
    tester,
  ) async {
    final connections = StreamController<bool>();
    addTearDown(connections.close);
    final client = CatalogTestClient();
    await _pumpCatalog(
      tester,
      client: client,
      connectionChanges: connections.stream,
    );
    await tester.pumpAndSettle();
    expect(find.text(detailsProduct.title!), findsOneWidget);
    connections.add(false);
    await tester.pumpAndSettle();
    expect(find.text('Нет соединения'), findsOneWidget);
    expect(find.text(detailsProduct.title!), findsOneWidget);
    client.products = [otherDetailsProduct];
    connections.add(true);
    await tester.pumpAndSettle();
    expect(find.text('Нет соединения'), findsNothing);
    expect(find.text(otherDetailsProduct.title!), findsOneWidget);
    expect(find.text(detailsProduct.title!), findsNothing);
    expect(client.requests, 2);
  });
}

DioException _timeout() => DioException(
  requestOptions: RequestOptions(path: '/products'),
  type: DioExceptionType.receiveTimeout,
);

Future<void> _pumpCatalog(
  WidgetTester tester, {
  required CatalogTestClient client,
  CatalogTestCache? cache,
  Stream<bool> connectionChanges = const Stream.empty(),
}) async {
  final repository = CatalogRepository(client, cache: cache);
  final cart = CartNotifierBloc(createCartRepository(MemoryCartPreferences()))
    ..add(const CartStarted());
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await cart.close();
    await repository.close();
  });
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CatalogRepository>.value(value: repository),
        RepositoryProvider<NetworkConnectionService>.value(
          value: TestNetworkConnectionService(connectionChanges),
        ),
      ],
      child: BlocProvider.value(value: cart, child: const ShopApp()),
    ),
  );
  await tester.pump();
}
