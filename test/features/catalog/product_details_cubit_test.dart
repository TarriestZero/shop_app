import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/catalog/data/mapper/catalog_product_mapper.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/presentation/product_details/bloc/product_details_cubit.dart';
import 'package:shop_app/features/catalog/presentation/catalog/bloc/catalog_cubit.dart';

import '../../support/catalog_test_support.dart';

void main() {
  late CatalogTestClient client;
  late CatalogTestCache cache;
  late CatalogRepository repository;
  late StreamController<bool> connections;
  final product = catalogProductFromDto(detailsProduct);

  setUp(() {
    client = CatalogTestClient();
    cache = CatalogTestCache();
    connections = StreamController<bool>();
    repository = CatalogRepository(
      client,
      cache: cache,
      connectionChanges: connections.stream,
    );
  });
  tearDown(() async {
    await repository.close();
    await connections.close();
  });

  test(
    'Открытие товара из офлайн-каталога сохраняет индикатор без запроса',
    () async {
      cache.products = const [detailsProduct];
      client.error = _connectionError();
      final catalog = CatalogCubit(repository);
      final details = ProductDetailsCubit(repository, productId: '1');
      addTearDown(() async {
        await catalog.close();
        await details.close();
      });
      await catalog.load();
      expect((catalog.state as CatalogLoaded).isOffline, isTrue);
      await details.load();
      expect(details.state, ProductDetailsLoaded(product, isOffline: true));
      expect(client.requests, 1);

      client.error = null;
      final restored = expectLater(
        details.stream,
        emits(ProductDetailsLoaded(product)),
      );
      await catalog.refresh();
      await restored;
      expect(details.state, ProductDetailsLoaded(product));
    },
  );

  test(
    'Потеря сети обновляет открытый товар и новый экран из памяти',
    () async {
      await repository.loadCatalog();
      final details = ProductDetailsCubit(repository, productId: '1');
      addTearDown(details.close);
      await details.load();
      final offline = expectLater(
        details.stream,
        emits(ProductDetailsLoaded(product, isOffline: true)),
      );
      connections.add(false);
      await offline;

      final reopened = ProductDetailsCubit(repository, productId: '1');
      addTearDown(reopened.close);
      await reopened.load();
      expect(reopened.state, ProductDetailsLoaded(product, isOffline: true));
      expect(client.requests, 1);
    },
  );

  test('Ошибка сети на странице товара обновляет индикатор каталога', () async {
    final catalog = CatalogCubit(repository);
    final details = ProductDetailsCubit(repository, productId: '1');
    addTearDown(() async {
      await catalog.close();
      await details.close();
    });
    await catalog.load();
    await details.load();
    client.error = _connectionError();
    await details.refresh();
    await Future<void>.delayed(Duration.zero);
    expect((catalog.state as CatalogLoaded).isOffline, isTrue);
    expect((details.state as ProductDetailsLoaded).isOffline, isTrue);
  });

  test('Запоздалый ответ не скрывает потерю сети во время запроса', () async {
    await repository.loadCatalog();
    final details = ProductDetailsCubit(repository, productId: '1');
    addTearDown(details.close);
    await details.load();
    final pending = Completer<List<ProductDto>>();
    client.fetch = () => pending.future;
    final refresh = details.refresh();
    connections.add(false);
    await Future<void>.delayed(Duration.zero);
    pending.complete(const [detailsProduct]);
    await refresh;
    expect(details.state, ProductDetailsLoaded(product, isOffline: true));

    connections.add(true);
    await Future<void>.delayed(Duration.zero);
    client.fetch = null;
    await details.refresh();
    expect(details.state, ProductDetailsLoaded(product));
  });

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'Товар из памяти открывается без повторного запроса',
    setUp: () => repository.loadCatalog(),
    build: () => ProductDetailsCubit(repository, productId: '1'),
    act: (cubit) => cubit.load(),
    expect: () => [ProductDetailsLoaded(product)],
    verify: (_) => expect(client.requests, 1),
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'Товар из кеша доступен без сети',
    setUp: () async {
      cache.products = const [detailsProduct];
      client.error = _connectionError();
      connections.add(false);
      await Future<void>.delayed(Duration.zero);
    },
    build: () => ProductDetailsCubit(repository, productId: '1'),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProductDetailsLoading(),
      ProductDetailsLoaded(product, isOffline: true),
    ],
    verify: (_) => expect(client.requests, 0),
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'Без кеша загружается общий каталог и сохраняется товар',
    build: () => ProductDetailsCubit(repository, productId: '1'),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProductDetailsLoading(),
      ProductDetailsLoaded(product),
    ],
    verify: (_) {
      expect(client.requests, 1);
      expect(repository.snapshot, [product]);
      expect(cache.products, [detailsProduct]);
    },
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'Первый запуск без кеша и сети показывает ошибку',
    setUp: () => client.error = _connectionError(),
    build: () => ProductDetailsCubit(repository, productId: '1'),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProductDetailsLoading(),
      const ProductDetailsLoadFailure(NetworkException.noConnection()),
    ],
    verify: (cubit) =>
        expect((cubit.state as ProductDetailsLoadFailure).isOffline, isTrue),
  );

  test('Обновление сохраняет данные до ответа, а ошибка сети оставляет товар офлайн', () async {
    cache.products = const [detailsProduct];
    final cubit = ProductDetailsCubit(repository, productId: '1');
    addTearDown(cubit.close);
    await cubit.load();
    final pending = Completer<List<ProductDto>>();
    client.fetch = () => pending.future;
    final refresh = cubit.refresh();
    expect(cubit.state, ProductDetailsRefreshing(product));

    pending.completeError(_connectionError());
    await refresh;
    expect(
      cubit.state,
      ProductDetailsRefreshFailure(
        product,
        const NetworkException.noConnection(),
      ),
    );
    expect((cubit.state as ProductDetailsLoaded).isOffline, isTrue);
    expect(repository.snapshot, [product]);
  });

  test('Внешнее обновление меняет товар, удаление скрывает его, возвращение восстанавливает', () async {
    cache.products = const [detailsProduct];
    final cubit = ProductDetailsCubit(repository, productId: '1');
    addTearDown(cubit.close);
    await cubit.load();

    const updated = ProductDto(
      id: 1,
      title: 'Обновлённая рубашка',
      price: 15,
      description: 'Новое описание',
    );
    client.products = const [updated];
    final changed = expectLater(
      cubit.stream,
      emits(ProductDetailsLoaded(catalogProductFromDto(updated))),
    );
    await repository.loadCatalog();
    await changed;
    expect(cubit.state, ProductDetailsLoaded(catalogProductFromDto(updated)));

    client.products = const [];
    final removed = expectLater(
      cubit.stream,
      emits(const ProductDetailsUnavailable()),
    );
    await repository.loadCatalog();
    await removed;
    expect(cubit.state, const ProductDetailsUnavailable());

    client.products = const [detailsProduct];
    final restored = expectLater(
      cubit.stream,
      emits(ProductDetailsLoaded(product)),
    );
    await repository.loadCatalog();
    await restored;
    expect(cubit.state, ProductDetailsLoaded(product));
  });

  for (final id in ['invalid', '999']) {
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'Некорректный или отсутствующий ID $id не вызывает лишних запросов',
      setUp: () => cache.products = const [detailsProduct],
      build: () => ProductDetailsCubit(repository, productId: id),
      act: (cubit) => cubit.load(),
      expect: () => id == 'invalid'
          ? [const ProductDetailsUnavailable()]
          : [const ProductDetailsLoading(), const ProductDetailsUnavailable()],
      verify: (_) => expect(client.requests, 0),
    );
  }

  test('Повторная загрузка использует текущий запрос; завершение после close безопасно', () async {
    final pending = Completer<List<ProductDto>>();
    client.fetch = () => pending.future;
    final cubit = ProductDetailsCubit(repository, productId: '1');
    final loading = cubit.load();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.refresh(), same(loading));
    expect(client.requests, 1);
    await cubit.close();
    pending.complete(const [detailsProduct]);
    await expectLater(loading, completes);
  });

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'Переход в корзину описан эффектом и сохраняет данные страницы',
    build: () => ProductDetailsCubit(repository, productId: '1'),
    seed: () => ProductDetailsLoaded(product),
    act: (cubit) {
      cubit.openCart();
      cubit.openCart();
    },
    expect: () => [
      const ProductDetailsCartSelected(),
      ProductDetailsLoaded(product),
      const ProductDetailsCartSelected(),
      ProductDetailsLoaded(product),
    ],
  );
}

DioException _connectionError() => DioException(
  requestOptions: RequestOptions(),
  type: DioExceptionType.connectionError,
);
