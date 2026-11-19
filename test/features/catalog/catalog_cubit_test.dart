import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';
import 'package:shop_app/features/catalog/presentation/catalog/bloc/catalog_cubit.dart';

const _cached = CatalogProduct(
  id: 1,
  title: 'Сохранённый товар',
  priceInCents: 1200,
  category: '',
  description: '',
);
const _fresh = CatalogProduct(
  id: 2,
  title: 'Новый товар',
  priceInCents: 2400,
  category: '',
  description: '',
);

void main() {
  late _Repository repository;

  setUp(() => repository = _Repository());

  blocTest<CatalogCubit, CatalogState>(
    'Shows cached data during refresh and replaces it on success',
    build: () {
      repository.cached = [_cached];
      return CatalogCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CatalogLoading(),
      CatalogLoaded([_cached]),
      CatalogRefreshing([_cached]),
      CatalogLoaded([_fresh]),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'Preserves cached data and marks it offline after a connection failure',
    build: () {
      repository.cached = [_cached];
      repository.fetch = () => Future.error(_connectionError());
      return CatalogCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CatalogLoading(),
      CatalogLoaded([_cached]),
      CatalogRefreshing([_cached]),
      CatalogRefreshFailure([
        _cached,
      ], exception: const NetworkException.noConnection()),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'Keeps data after a server refresh failure',
    build: () {
      repository.fetch = () =>
          Future.error(const NetworkException.server(statusCode: 503));
      return CatalogCubit(repository);
    },
    seed: () => CatalogLoaded([_cached]),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      CatalogRefreshing([_cached]),
      CatalogRefreshFailure([
        _cached,
      ], exception: const NetworkException.server(statusCode: 503)),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'Distinguishes a valid empty catalog from a missing cache',
    build: () {
      repository.cached = [];
      repository.fetch = () async => [];
      return CatalogCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CatalogLoading(),
      CatalogEmpty(),
      CatalogRefreshing([]),
      CatalogEmpty(),
    ],
  );

  test('Concurrent refreshes share one request', () async {
    final pending = Completer<List<CatalogProduct>>();
    repository.fetch = () => pending.future;
    final cubit = CatalogCubit(repository);
    addTearDown(cubit.close);

    final first = cubit.refresh();
    final second = cubit.refresh();
    expect(identical(first, second), isTrue);
    pending.complete([_fresh]);
    await Future.wait([first, second]);

    expect(repository.requests, 1);
    expect(cubit.state, CatalogLoaded([_fresh]));
  });

  blocTest<CatalogCubit, CatalogState>(
    'Repeated selection emits a new navigation effect while preserving data',
    build: () => CatalogCubit(repository),
    seed: () => CatalogLoaded([_cached]),
    act: (cubit) {
      cubit.openProduct(1);
      cubit.openProduct(1);
    },
    expect: () => [
      const CatalogProductSelected(1),
      CatalogLoaded([_cached]),
      const CatalogProductSelected(1),
      CatalogLoaded([_cached]),
    ],
  );

  test('A request completing after close does not emit', () async {
    final pending = Completer<List<CatalogProduct>>();
    repository.fetch = () => pending.future;
    final cubit = CatalogCubit(repository);
    final loading = cubit.load();
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    pending.complete([_fresh]);

    await expectLater(loading, completes);
  });

  testWidgets('Retries pause in the background and resume with the app', (
    tester,
  ) async {
    repository.fetch = () => Future.error(_connectionError());
    final cubit = CatalogCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.setActive(false);
    await tester.pump(const Duration(seconds: 10));
    expect(repository.requests, 1);

    repository.fetch = () async => [_fresh];
    cubit.setActive(true);
    await tester.pump();
    expect(repository.requests, 2);
    expect(cubit.state, CatalogLoaded([_fresh]));
  });

  testWidgets('Automatically retries after a network failure', (tester) async {
    repository.fetch = () => Future.error(_connectionError());
    final cubit = CatalogCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    repository.fetch = () async => [_fresh];

    await tester.pump(const Duration(seconds: 2));
    expect(repository.requests, 2);
    expect(cubit.state, CatalogLoaded([_fresh]));
  });
}

NetworkException _connectionError() => const NetworkException.noConnection();

class _Repository extends Fake implements CatalogRepository {
  List<CatalogProduct>? cached;
  Future<List<CatalogProduct>> Function() fetch = () async => [_fresh];
  int requests = 0;

  @override
  Future<List<CatalogProduct>?> getCachedCatalog() async => cached;

  @override
  Future<List<CatalogProduct>> loadCatalog() {
    requests += 1;
    return fetch();
  }
}
