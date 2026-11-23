import 'dart:async';

import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/api/source/products_api_source.dart';
import 'package:shop_app/core/exceptions/network_exception.dart';
import 'package:shop_app/core/network/response_guard.dart';
import 'package:shop_app/features/catalog/data/local/catalog_local_data_source.dart';
import 'package:shop_app/features/catalog/data/mapper/catalog_product_mapper.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';

/// Репозиторий каталога, работающий через клиент товаров.
class CatalogRepository {
  CatalogRepository(
    this._client, {
    this._cache,
    Stream<bool>? connectionChanges,
  }) {
    _connectionSubscription = connectionChanges?.distinct().listen((connected) {
      _connectionVersion++;
      if (!connected) _setOffline(true);
    }, onError: (Object _) {});
  }

  final ProductsApiSource _client;
  final CatalogLocalDataSource? _cache;
  final _changes = StreamController<List<CatalogProduct>>.broadcast();
  final _offlineChanges = StreamController<bool>.broadcast();
  List<CatalogProduct>? _snapshot;
  Future<List<CatalogProduct>?>? _pendingCacheRead;
  Future<List<CatalogProduct>>? _pendingLoad;
  StreamSubscription<bool>? _connectionSubscription;
  int _connectionVersion = 0;
  bool _isOffline = false;

  /// Последний полный снимок. `null` означает, что каталог ещё не загружен.
  List<CatalogProduct>? get snapshot => _snapshot;

  /// Общий признак отсутствия сети. Сбрасывается успешным запросом каталога.
  bool get isOffline => _isOffline;

  /// Отдаёт признак офлайна и его изменения, даже если каталог ещё не загружен.
  Stream<bool> get offlineChanges => Stream.multi((controller) {
    final subscription = _offlineChanges.stream.listen(
      controller.add,
      onDone: controller.close,
    );
    controller.add(_isOffline);
    controller.onCancel = subscription.cancel;
  });

  /// Отдаёт снимок при подписке, изменении товаров или признака офлайна.
  Stream<List<CatalogProduct>> get changes => Stream.multi((controller) {
    final subscription = _changes.stream.listen(
      controller.add,
      onDone: controller.close,
    );
    final current = _snapshot;
    if (current != null) controller.add(current);
    controller.onCancel = subscription.cancel;
  });

  /// Читает последний полный каталог для офлайн-запуска.
  Future<List<CatalogProduct>?> getCachedCatalog() {
    if (_snapshot != null) return Future.value(_snapshot);
    return _pendingCacheRead ??= _readCache().whenComplete(() {
      _pendingCacheRead = null;
    });
  }

  Future<List<CatalogProduct>?> _readCache() async {
    try {
      final products = await _cache?.read();
      final cached = products
          ?.map(catalogProductFromDto)
          .toList(growable: false);
      // Завершившееся обновление имеет приоритет над более старым чтением кеша.
      if (_snapshot != null) return _snapshot;
      return cached == null ? null : _publish(cached);
    } on FormatException {
      return _snapshot;
    }
  }

  /// Загружает, проверяет и сохраняет полный каталог.
  Future<List<CatalogProduct>> loadCatalog() =>
      _pendingLoad ??= _fetchCatalog().whenComplete(() {
        _pendingLoad = null;
      });

  Future<List<CatalogProduct>> _fetchCatalog() async {
    final connectionVersion = _connectionVersion;
    try {
      final products = await guardNetwork(() async {
        final response = await _client.getProducts();
        final products = response
            .map(catalogProductFromDto)
            .toList(growable: false);
        await _cache?.write(response);
        return products;
      });
      if (connectionVersion == _connectionVersion) {
        _setOffline(false, publishSnapshot: false);
      }
      return _publish(products);
    } on NetworkException catch (error) {
      if (error.type == NetworkErrorType.noConnection) _setOffline(true);
      rethrow;
    }
  }

  void _setOffline(bool offline, {bool publishSnapshot = true}) {
    if (_isOffline == offline) return;
    _isOffline = offline;
    if (!_offlineChanges.isClosed) _offlineChanges.add(offline);
    final current = _snapshot;
    if (publishSnapshot && current != null && !_changes.isClosed) {
      _changes.add(current);
    }
  }

  List<CatalogProduct> _publish(List<CatalogProduct> products) {
    final snapshot = _snapshot = List<CatalogProduct>.unmodifiable(products);
    if (!_changes.isClosed) _changes.add(snapshot);
    return snapshot;
  }

  /// Закрывает поток каталога при освобождении корневых зависимостей.
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    await _offlineChanges.close();
    await _changes.close();
  }

  /// Получает товары с ограничением количества и сортировкой.
  Future<List<ProductDto>> getProducts({int? limit, ApiSortOrder? sort}) =>
      guardNetwork(() => _client.getProducts(limit: limit, sort: sort));

  /// Получает товар по ID или возвращает `null`, если он отсутствует.
  Future<ProductDto?> getProduct(int id) =>
      guardNetwork(() => _client.getProduct(id));

  /// Получает доступные категории товаров.
  Future<List<String>> getCategories() => guardNetwork(_client.getCategories);

  /// Получает товары выбранной категории.
  Future<List<ProductDto>> getProductsByCategory(
    String category, {
    int? limit,
    ApiSortOrder? sort,
  }) => guardNetwork(
    () => _client.getProductsByCategory(category, limit: limit, sort: sort),
  );

  /// Отправляет данные нового товара.
  Future<ProductDto> createProduct(ProductRequestDto body) =>
      guardNetwork(() => _client.createProduct(body));

  /// Отправляет полное обновление товара.
  Future<ProductDto> updateProduct(int id, ProductRequestDto body) =>
      guardNetwork(() => _client.updateProduct(id, body));

  /// Отправляет изменённые поля товара.
  Future<ProductDto> patchProduct(int id, ProductRequestDto body) =>
      guardNetwork(() => _client.patchProduct(id, body));

  /// Запрашивает удаление товара и возвращает его данные, если он найден.
  Future<ProductDto?> deleteProduct(int id) =>
      guardNetwork(() => _client.deleteProduct(id));
}
