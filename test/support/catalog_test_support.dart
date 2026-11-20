import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/api/source/products_api_source.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/catalog/data/local/catalog_local_data_source.dart';

const detailsProduct = ProductDto(
  id: 1,
  title: 'Льняная рубашка',
  price: 10.99,
  category: 'Одежда',
  description: 'Рубашка из натурального льна. Свободный крой.',
);

const otherDetailsProduct = ProductDto(
  id: 2,
  title: 'Наушники',
  price: 35,
  category: 'Электроника',
  description: 'Беспроводные наушники.',
);

class CatalogTestClient extends Fake implements ProductsApiSource {
  List<ProductDto> products = const [detailsProduct];
  Object? error;
  Future<List<ProductDto>> Function()? fetch;
  int requests = 0;

  @override
  Future<List<ProductDto>> getProducts({int? limit, ApiSortOrder? sort}) async {
    requests++;
    final action = fetch;
    if (action != null) return action();
    final failure = error;
    if (failure != null) throw failure;
    return products;
  }
}

class CatalogTestCache extends Fake implements CatalogLocalDataSource {
  List<ProductDto>? products;
  Future<List<ProductDto>?> Function()? fetch;
  bool failWrites = false;
  int reads = 0;

  @override
  Future<List<ProductDto>?> read() async {
    reads++;
    final action = fetch;
    return action == null ? products : action();
  }

  @override
  Future<void> write(List<ProductDto> value) async {
    if (failWrites) throw const StorageException.write();
    products = List.unmodifiable(value);
  }
}
