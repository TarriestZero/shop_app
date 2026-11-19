import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shop_app/api/api_config.dart';
import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/cart_dto.dart';

part 'carts_api_source.g.dart';

@RestApi(baseUrl: ApiConfig.baseUrl)
abstract class CartsApiSource {
  factory CartsApiSource(Dio dio, {String? baseUrl}) = _CartsApiSource;

  /// Получает корзины. Даты фильтра передаются в формате `YYYY-MM-DD`.
  @GET('/carts')
  Future<List<CartDto>> getCarts({
    @Query('limit') int? limit,
    @Query('sort') ApiSortOrder? sort,
    @Query('startdate') String? startDate,
    @Query('enddate') String? endDate,
  });

  /// Получает корзину по ID. Возвращает `null`, если корзина отсутствует.
  @GET('/carts/{id}')
  Future<CartDto?> getCart(@Path('id') int id);

  /// Получает корзины пользователя с фильтром дат в формате `YYYY-MM-DD`.
  @GET('/carts/user/{userId}')
  Future<List<CartDto>> getUserCarts(
    @Path('userId') int userId, {
    @Query('startdate') String? startDate,
    @Query('enddate') String? endDate,
  });

  /// Отправляет данные новой корзины.
  @POST('/carts')
  Future<CartDto> createCart(@Body() CartRequestDto body);

  /// Отправляет полное обновление корзины.
  @PUT('/carts/{id}')
  Future<CartDto> updateCart(@Path('id') int id, @Body() CartRequestDto body);

  /// Отправляет изменённые поля корзины.
  @PATCH('/carts/{id}')
  Future<CartDto> patchCart(@Path('id') int id, @Body() CartRequestDto body);

  /// Запрашивает удаление корзины и возвращает данные найденной корзины.
  @DELETE('/carts/{id}')
  Future<CartDto?> deleteCart(@Path('id') int id);
}
