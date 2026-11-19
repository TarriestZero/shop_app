import 'package:shop_app/api/dto/auth_dto.dart';
import 'package:shop_app/api/source/auth_api_source.dart';

/// Репозиторий авторизации, работающий через клиент входа.
class AuthRepository {
  const AuthRepository(this._client);

  final AuthApiSource _client;

  /// Выполняет вход по переданным учётным данным и возвращает токен.
  Future<LoginResponseDto> login(LoginRequestDto body) => _client.login(body);
}
