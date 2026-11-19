import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/user_dto.dart';
import 'package:shop_app/api/source/users_api_source.dart';

/// Репозиторий пользователей, работающий через клиент пользователей.
class UsersRepository {
  const UsersRepository(this._client);

  final UsersApiSource _client;

  /// Получает пользователей с ограничением количества и сортировкой.
  Future<List<UserDto>> getUsers({int? limit, ApiSortOrder? sort}) =>
      _client.getUsers(limit: limit, sort: sort);

  /// Получает пользователя по ID или возвращает `null`, если он отсутствует.
  Future<UserDto?> getUser(int id) => _client.getUser(id);

  /// Отправляет данные нового пользователя.
  Future<UserDto> createUser(UserRequestDto body) => _client.createUser(body);

  /// Отправляет полное обновление пользователя.
  Future<UserDto> updateUser(int id, UserRequestDto body) =>
      _client.updateUser(id, body);

  /// Отправляет изменённые поля пользователя.
  Future<UserDto> patchUser(int id, UserRequestDto body) =>
      _client.patchUser(id, body);

  /// Запрашивает удаление пользователя и возвращает его данные, если он найден.
  Future<UserDto?> deleteUser(int id) => _client.deleteUser(id);
}
