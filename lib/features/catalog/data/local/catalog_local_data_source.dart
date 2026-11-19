import 'package:flutter/services.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/core/storage/shared_preferences_service.dart';

/// Хранит полный снимок каталога в shared_preferences.
class CatalogLocalDataSource {
  const CatalogLocalDataSource(this._storage);

  final SharedPreferencesService _storage;
  static const _key = 'catalog_snapshot';
  static const _version = 1;

  /// Возвращает снимок или `null`, если кеш отсутствует или недоступен.
  Future<List<ProductDto>?> read() async {
    try {
      final snapshot = await _storage.getJson(_key);
      if (snapshot == null || snapshot['version'] != _version) return null;

      final products = snapshot['products'];
      if (products is! List) return null;

      return products
          .map(
            (item) =>
                ProductDto.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Сохраняет товары и метаданные одной JSON-строкой.
  Future<void> write(List<ProductDto> products) async {
    try {
      await _storage.setJson(_key, {
        'version': _version,
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        'products': products
            .map((product) => product.toJson())
            .toList(growable: false),
      });
    } on AppException {
      rethrow;
    } on Exception catch (_, stackTrace) {
      Error.throwWithStackTrace(const StorageException.write(), stackTrace);
    }
  }
}
