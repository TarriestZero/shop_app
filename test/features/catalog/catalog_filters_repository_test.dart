import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_filters_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_filters.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';

const products = [
  CatalogProduct(
    id: 1,
    title: 'A',
    priceInCents: 1000,
    category: ' clothes ',
    description: '',
  ),
  CatalogProduct(
    id: 2,
    title: 'B',
    priceInCents: 2000,
    category: 'clothes',
    description: '',
  ),
  CatalogProduct(
    id: 3,
    title: 'C',
    priceInCents: 1500,
    category: 'electronics',
    description: '',
  ),
  CatalogProduct(
    id: 4,
    title: 'D',
    priceInCents: 3000,
    category: 'electronics',
    description: '',
  ),
];

void main() {
  test(
    'Categories and inclusive price boundaries share the same count predicate',
    () async {
      final repository = CatalogFiltersRepository(products);
      addTearDown(repository.close);
      final filters = CatalogFilters(
        categories: {'clothes'},
        minimumPriceInCents: 1000,
        maximumPriceInCents: 2000,
      );
      expect(repository.filter(filters).map((product) => product.id), [1, 2]);
      expect(await repository.count(filters), 2);
      expect(
        repository
            .filter(
              CatalogFilters(
                categories: {'clothes', 'electronics'},
                maximumPriceInCents: 1500,
              ),
            )
            .map((product) => product.id),
        [1, 3],
      );
      expect(repository.filter(const CatalogFilters.empty()), products);
      expect(
        await repository.count(CatalogFilters(minimumPriceInCents: 4000)),
        0,
      );
    },
  );

  test(
    'The snapshot and selected categories cannot change from outside',
    () async {
      final source = [...products];
      final categories = {'clothes'};
      final repository = CatalogFiltersRepository(source);
      addTearDown(repository.close);
      final filters = CatalogFilters(categories: categories);
      source.clear();
      categories.clear();
      expect(await repository.count(filters), 2);
      expect(() => filters.categories.clear(), throwsUnsupportedError);
    },
  );
}
