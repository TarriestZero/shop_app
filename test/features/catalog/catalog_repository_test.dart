import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/api/source/products_api_source.dart';
import 'package:shop_app/core/storage/shared_preferences_service.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/catalog/data/local/catalog_local_data_source.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';

void main() {
  late _Client client;
  late _Storage storage;
  late CatalogRepository repository;

  setUp(() {
    client = _Client();
    storage = _Storage();
    repository = CatalogRepository(
      client,
      cache: CatalogLocalDataSource(storage),
    );
  });

  test('A new repository restores the complete saved catalog', () async {
    final loaded = await repository.loadCatalog();
    final restarted = CatalogRepository(
      client,
      cache: CatalogLocalDataSource(storage),
    );

    expect(loaded.single.priceInCents, 1099);
    expect(await restarted.getCachedCatalog(), loaded);
    expect(storage.snapshot?['version'], 1);
    expect(storage.snapshot?['savedAt'], isA<String>());
  });

  test(
    'Invalid and unsupported cache data is treated as a cache miss',
    () async {
      storage.snapshot = {'version': 2, 'products': []};
      expect(await repository.getCachedCatalog(), isNull);
      storage.snapshot = {
        'version': 1,
        'products': [5],
      };
      expect(await repository.getCachedCatalog(), isNull);
      storage.snapshot = {
        'version': 1,
        'products': [
          {'id': 1},
        ],
      };
      expect(await repository.getCachedCatalog(), isNull);
    },
  );

  test(
    'An invalid server product leaves the previous complete snapshot intact',
    () async {
      await repository.loadCatalog();
      final previous = storage.snapshot;
      client.products = const [ProductDto(id: 2, title: 'Без цены')];

      await expectLater(
        repository.loadCatalog(),
        throwsA(
          isA<NetworkException>().having(
            (error) => error.type,
            'type',
            NetworkErrorType.invalidResponse,
          ),
        ),
      );
      expect(storage.snapshot, same(previous));
    },
  );

  test('A storage write failure preserves the previous snapshot', () async {
    await repository.loadCatalog();
    final previous = storage.snapshot;
    storage.failWrites = true;

    await expectLater(
      repository.loadCatalog(),
      throwsA(isA<StorageException>()),
    );
    expect(storage.snapshot, same(previous));
  });
}

class _Client extends Fake implements ProductsApiSource {
  List<ProductDto> products = const [
    ProductDto(id: 1, title: 'Товар', price: 10.99),
  ];

  @override
  Future<List<ProductDto>> getProducts({
    int? limit,
    ApiSortOrder? sort,
  }) async => products;
}

class _Storage extends Fake implements SharedPreferencesService {
  Map<String, Object?>? snapshot;
  bool failWrites = false;

  @override
  Future<Map<String, Object?>?> getJson(String key) async => snapshot;

  @override
  Future<void> setJson(String key, Map<String, Object?> value) async {
    if (failWrites) throw PlatformException(code: 'write_failed');
    snapshot = value;
  }
}
