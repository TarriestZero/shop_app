import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/cart_dto.dart';
import 'package:shop_app/api/source/carts_api_source.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/cart/data/local/cart_local_data_source.dart';
import 'package:shop_app/features/cart/data/repositories/cart_repository.dart';

import '../../support/cart_test_support.dart';

const _cart = CartDto(
  id: 7,
  userId: 2,
  products: [CartProductDto(productId: 1, quantity: 3)],
);

void main() {
  late _Client client;
  late MemoryCartPreferences preferences;
  late CartRepository repository;

  setUp(() {
    client = _Client();
    preferences = MemoryCartPreferences();
    repository = CartRepository(
      client,
      storage: CartLocalDataSource(preferences),
    );
  });

  test(
    'Успешная загрузка возвращает корзины и передаёт параметры запроса',
    () async {
      client.carts = const [_cart];
      final result = await repository.getCarts(
        limit: 5,
        sort: ApiSortOrder.desc,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      expect(result, [_cart]);
      expect(result.single.products!.single.quantity, 3);
      expect(client.query, (
        limit: 5,
        sort: ApiSortOrder.desc,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      ));
      expect(preferences.writes, 0);
    },
  );

  test('Пустой ответ API не удаляет локальную корзину', () async {
    await repository.add(cartProduct.withQuantity(2));
    final snapshot = preferences.snapshot;

    expect(await repository.getCarts(), isEmpty);
    expect(await repository.load(), [cartProduct.withQuantity(2)]);
    expect(preferences.snapshot, same(snapshot));
  });

  for (final (type, expectedType) in [
    (DioExceptionType.connectionError, NetworkErrorType.noConnection),
    (DioExceptionType.receiveTimeout, NetworkErrorType.timeout),
  ]) {
    test(
      'Ошибка $type преобразуется в исключение приложения и сохраняет офлайн-корзину',
      () async {
        await repository.add(cartProduct.withQuantity(2));
        final snapshot = preferences.snapshot;
        client.error = DioException(
          requestOptions: RequestOptions(path: '/carts'),
          type: type,
        );

        await expectLater(
          repository.getCarts(),
          throwsA(
            isA<NetworkException>()
                .having((error) => error.type, 'type', expectedType)
                .having(
                  (error) => error.isConnectionError,
                  'isConnectionError',
                  true,
                ),
          ),
        );
        expect(await repository.load(), [cartProduct.withQuantity(2)]);
        expect(preferences.snapshot, same(snapshot));
        expect(await createCartRepository(preferences).load(), [
          cartProduct.withQuantity(2),
        ]);
      },
    );
  }

  test('HTTP 503 возвращает ошибку сервера с исходным статусом', () async {
    final options = RequestOptions(path: '/carts');
    client.error = DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: 503),
    );

    await expectLater(
      repository.getCarts(),
      throwsA(
        isA<NetworkException>()
            .having((error) => error.type, 'type', NetworkErrorType.server)
            .having((error) => error.statusCode, 'statusCode', 503)
            .having(
              (error) => error.isConnectionError,
              'isConnectionError',
              false,
            ),
      ),
    );
    expect(preferences.writes, 0);
  });

  test(
    'Загрузка одной корзины поддерживает успешный и отсутствующий результат',
    () async {
      client.cart = _cart;
      expect(await repository.getCart(7), same(_cart));
      expect(client.cartId, 7);

      client.cart = null;
      expect(await repository.getCart(99), isNull);
      expect(client.cartId, 99);
    },
  );

  test(
    'Загрузка корзин пользователя поддерживает список и пустой ответ',
    () async {
      client.carts = const [_cart];
      expect(
        await repository.getUserCarts(
          2,
          startDate: '2026-01-01',
          endDate: '2026-01-31',
        ),
        [_cart],
      );
      expect(client.userQuery, (
        userId: 2,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      ));

      client.carts = const [];
      expect(await repository.getUserCarts(2), isEmpty);
      expect(preferences.writes, 0);
    },
  );
}

class _Client extends Fake implements CartsApiSource {
  List<CartDto> carts = const [];
  CartDto? cart;
  DioException? error;
  int? cartId;
  ({int? limit, ApiSortOrder? sort, String? startDate, String? endDate})? query;
  ({int userId, String? startDate, String? endDate})? userQuery;

  @override
  Future<List<CartDto>> getCarts({
    int? limit,
    ApiSortOrder? sort,
    String? startDate,
    String? endDate,
  }) async {
    query = (limit: limit, sort: sort, startDate: startDate, endDate: endDate);
    final failure = error;
    if (failure != null) throw failure;
    return carts;
  }

  @override
  Future<CartDto?> getCart(int id) async {
    cartId = id;
    return cart;
  }

  @override
  Future<List<CartDto>> getUserCarts(
    int userId, {
    String? startDate,
    String? endDate,
  }) async {
    userQuery = (userId: userId, startDate: startDate, endDate: endDate);
    return carts;
  }
}
