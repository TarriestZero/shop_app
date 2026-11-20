import 'package:equatable/equatable.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';

/// Фильтры каталога. Отсутствие границы цены означает неограниченный диапазон.
class CatalogFilters extends Equatable {
  const CatalogFilters.empty()
    : categories = const {},
      minimumPriceInCents = null,
      maximumPriceInCents = null;

  CatalogFilters({
    Set<String> categories = const {},
    this.minimumPriceInCents,
    this.maximumPriceInCents,
  }) : categories = Set.unmodifiable(categories);

  final Set<String> categories;
  final int? minimumPriceInCents;
  final int? maximumPriceInCents;

  bool get isEmpty =>
      categories.isEmpty &&
      minimumPriceInCents == null &&
      maximumPriceInCents == null;

  /// Проверяет товар по всем выбранным условиям, включая границы цены.
  bool matches(CatalogProduct product) =>
      (categories.isEmpty || categories.contains(product.category.trim())) &&
      (minimumPriceInCents == null ||
          product.priceInCents >= minimumPriceInCents!) &&
      (maximumPriceInCents == null ||
          product.priceInCents <= maximumPriceInCents!);

  @override
  List<Object?> get props => [
    categories,
    minimumPriceInCents,
    maximumPriceInCents,
  ];
}
