import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shop_app/api/api_config.dart';
import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/core/network/empty_response_interceptor.dart';

part 'products_api_source.g.dart';

@RestApi(baseUrl: ApiConfig.baseUrl)
abstract class ProductsApiSource {
  factory ProductsApiSource(Dio dio, {String? baseUrl}) = _ProductsApiSource;

  /// Получает товары с ограничением количества и сортировкой по ID.
  @GET('/products')
  Future<List<ProductDto>> getProducts({
    @Query('limit') int? limit,
    @Query('sort') ApiSortOrder? sort,
  });

  /// Получает товар по ID. Возвращает `null`, если товар отсутствует.
  @GET('/products/{id}')
  @Extra({EmptyResponseInterceptor.allowEmptyResponse: true})
  Future<ProductDto?> getProduct(@Path('id') int id);

  /// Получает названия всех категорий.
  @GET('/products/categories')
  Future<List<String>> getCategories();

  /// Получает товары выбранной категории.
  @GET('/products/category/{category}')
  Future<List<ProductDto>> getProductsByCategory(
    @Path('category') String category, {
    @Query('limit') int? limit,
    @Query('sort') ApiSortOrder? sort,
  });

  /// Отправляет данные нового товара.
  @POST('/products')
  Future<ProductDto> createProduct(@Body() ProductRequestDto body);

  /// Отправляет полное обновление товара.
  @PUT('/products/{id}')
  Future<ProductDto> updateProduct(
    @Path('id') int id,
    @Body() ProductRequestDto body,
  );

  /// Отправляет изменённые поля товара.
  @PATCH('/products/{id}')
  Future<ProductDto> patchProduct(
    @Path('id') int id,
    @Body() ProductRequestDto body,
  );

  /// Запрашивает удаление товара и возвращает данные найденного товара.
  @DELETE('/products/{id}')
  @Extra({EmptyResponseInterceptor.allowEmptyResponse: true})
  Future<ProductDto?> deleteProduct(@Path('id') int id);
}
