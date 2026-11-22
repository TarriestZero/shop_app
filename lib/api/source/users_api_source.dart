import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shop_app/api/api_config.dart';
import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/user_dto.dart';
import 'package:shop_app/core/network/empty_response_interceptor.dart';

part 'users_api_source.g.dart';

@RestApi(baseUrl: ApiConfig.baseUrl)
abstract class UsersApiSource {
  factory UsersApiSource(Dio dio, {String? baseUrl}) = _UsersApiSource;

  /// Получает пользователей с ограничением количества и сортировкой по ID.
  @GET('/users')
  Future<List<UserDto>> getUsers({
    @Query('limit') int? limit,
    @Query('sort') ApiSortOrder? sort,
  });

  /// Получает пользователя по ID. Возвращает `null`, если он отсутствует.
  @GET('/users/{id}')
  @Extra({EmptyResponseInterceptor.allowEmptyResponse: true})
  Future<UserDto?> getUser(@Path('id') int id);

  /// Отправляет данные нового пользователя.
  @POST('/users')
  Future<UserDto> createUser(@Body() UserRequestDto body);

  /// Отправляет полное обновление пользователя.
  @PUT('/users/{id}')
  Future<UserDto> updateUser(@Path('id') int id, @Body() UserRequestDto body);

  /// Отправляет изменённые поля пользователя.
  @PATCH('/users/{id}')
  Future<UserDto> patchUser(@Path('id') int id, @Body() UserRequestDto body);

  /// Запрашивает удаление пользователя и возвращает его данные.
  @DELETE('/users/{id}')
  @Extra({EmptyResponseInterceptor.allowEmptyResponse: true})
  Future<UserDto?> deleteUser(@Path('id') int id);
}
