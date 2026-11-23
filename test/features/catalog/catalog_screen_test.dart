import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/app/shop_app.dart';
import 'package:shop_app/core/exceptions/network_exception.dart';
import 'package:shop_app/core/network/network_connection_service.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/presentation/product_details/screen/product_details_screen.dart';

import '../../support/cart_test_support.dart';
import '../../support/catalog_test_support.dart';
import '../../support/network_test_support.dart';

const _timeoutMessage = 'Истекло время ожидания ответа. Попробуйте ещё раз.';

void main() {
  testWidgets(
    'Индикатор офлайна сохраняется при открытии товара и исчезает после повтора',
    (tester) async {
      final client = CatalogTestClient()
        ..error = const NetworkException.noConnection();
      await _pumpCatalog(
        tester,
        client: client,
        cache: CatalogTestCache()..products = [detailsProduct],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(detailsProduct.title!));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      expect(find.text('Нет соединения'), findsOneWidget);
      expect(client.requests, 1);

      client.error = null;
      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpAndSettle();
      expect(find.text('Нет соединения'), findsNothing);
      expect(client.requests, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Каталог на узком экране поддерживает шрифт 200% и корзину', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() async {
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await tester.binding.setSurfaceSize(null);
    });
    final client = CatalogTestClient()
      ..products = const [
        ProductDto(
          id: 1,
          title: 'Длинное название товара для двух строк',
          price: 10,
          category: 'Категория',
        ),
      ];
    await _pumpCatalog(tester, client: client);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final grid = tester.widget<GridView>(find.byType(GridView));
    final card = find.byTooltip('В корзину');
    expect(grid.childrenDelegate.estimatedChildCount, 1);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Увеличить количество'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final error in [
    const NetworkException.server(statusCode: 503),
    const NetworkException.noConnection(),
  ]) {
    testWidgets(
      'Повтор обновления после ${error.type} сохраняет каталог до ответа',
      (tester) async {
        final client = CatalogTestClient()..error = error;
        await _pumpCatalog(
          tester,
          client: client,
          cache: CatalogTestCache()..products = [detailsProduct],
        );
        await tester.pumpAndSettle();
        expect(find.text(detailsProduct.title!), findsOneWidget);
        expect(find.text('Повторить'), findsOneWidget);
        if (error.type == NetworkErrorType.noConnection) {
          expect(find.text('Нет соединения'), findsOneWidget);
        }

        final pending = Completer<List<ProductDto>>();
        client.fetch = () => pending.future;
        await tester.tap(find.text('Повторить'));
        await tester.pump();
        expect(client.requests, 2);
        expect(find.text(detailsProduct.title!), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        pending.complete([otherDetailsProduct]);
        await tester.pumpAndSettle();
        expect(find.text(otherDetailsProduct.title!), findsOneWidget);
        expect(find.text(detailsProduct.title!), findsNothing);
        expect(find.text('Нет соединения'), findsNothing);
      },
    );
  }

  for (final (error, message) in [
    (
      const NetworkException.client(statusCode: 409),
      'Сервер отклонил запрос. Проверьте данные и попробуйте ещё раз.',
    ),
    (
      const NetworkException.emptyResponse(statusCode: 204),
      'Сервер вернул пустой ответ. Попробуйте ещё раз.',
    ),
  ]) {
    testWidgets('Каталог показывает отдельное сообщение для ${error.type}', (
      tester,
    ) async {
      final client = CatalogTestClient()..error = error;
      await _pumpCatalog(tester, client: client);
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      expect(find.text('Нет соединения'), findsNothing);
      expect(find.text('Не удалось обработать данные сервера'), findsNothing);
      expect(find.text('В каталоге пока нет товаров'), findsNothing);
      client.error = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Повторить'));
      await tester.pumpAndSettle();
      expect(find.text(detailsProduct.title!), findsOneWidget);
    });
  }

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
