import 'dart:async';

import 'package:shop_app/features/catalog/domain/entity/catalog_filters.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';
import 'package:shop_app/features/filters/domain/repository/filters_repository.dart';

/// Фильтрует полный загруженный снимок каталога без обращения к API.
class CatalogFiltersRepository extends FiltersRepository<CatalogFilters> {
  CatalogFiltersRepository(List<CatalogProduct> products)
    : _products = List.unmodifiable(products);

  List<CatalogProduct> _products;
  final _changes = StreamController<void>.broadcast();

  /// Полный текущий снимок товаров, доступный только для чтения.
  List<CatalogProduct> get products => _products;

  @override
  Stream<void> get changes => _changes.stream;

  /// Обновляет исходные товары и уведомляет открытый контроллер фильтров.
  void updateProducts(List<CatalogProduct> products) {
    _products = List.unmodifiable(products);
    _changes.add(null);
  }

  /// Возвращает подходящие товары, сохраняя исходный порядок.
  List<CatalogProduct> filter(CatalogFilters filters) =>
      _products.where(filters.matches).toList(growable: false);

  @override
  Future<int> count(CatalogFilters filters) async =>
      _products.where(filters.matches).length;

  /// Закрывает поток изменений. Вызывается владельцем репозитория.
  Future<void> close() => _changes.close();
}
