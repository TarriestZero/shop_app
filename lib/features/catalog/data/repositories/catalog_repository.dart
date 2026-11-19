import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/api/source/products_api_source.dart';

/// Репозиторий каталога, работающий через клиент товаров.
class CatalogRepository {
  const CatalogRepository(this._client);

  final ProductsApiSource _client;

  /// Получает товары с ограничением количества и сортировкой.
  Future<List<ProductDto>> getProducts({int? limit, ApiSortOrder? sort}) =>
      _client.getProducts(limit: limit, sort: sort);

  /// Получает товар по ID или возвращает `null`, если он отсутствует.
  Future<ProductDto?> getProduct(int id) => _client.getProduct(id);

  /// Получает доступные категории товаров.
  Future<List<String>> getCategories() => _client.getCategories();

  /// Получает товары выбранной категории.
  Future<List<ProductDto>> getProductsByCategory(
    String category, {
    int? limit,
    ApiSortOrder? sort,
  }) => _client.getProductsByCategory(category, limit: limit, sort: sort);

  /// Отправляет данные нового товара.
  Future<ProductDto> createProduct(ProductRequestDto body) =>
      _client.createProduct(body);

  /// Отправляет полное обновление товара.
  Future<ProductDto> updateProduct(int id, ProductRequestDto body) =>
      _client.updateProduct(id, body);

  /// Отправляет изменённые поля товара.
  Future<ProductDto> patchProduct(int id, ProductRequestDto body) =>
      _client.patchProduct(id, body);

  /// Запрашивает удаление товара и возвращает его данные, если он найден.
  Future<ProductDto?> deleteProduct(int id) => _client.deleteProduct(id);
}
