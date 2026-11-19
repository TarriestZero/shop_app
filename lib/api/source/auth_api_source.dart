import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shop_app/api/api_config.dart';
import 'package:shop_app/api/dto/auth_dto.dart';

part 'auth_api_source.g.dart';

@RestApi(baseUrl: ApiConfig.baseUrl)
abstract class AuthApiSource {
  factory AuthApiSource(Dio dio, {String? baseUrl}) = _AuthApiSource;

  /// Выполняет вход по логину и паролю и возвращает токен.
  @POST('/auth/login')
  Future<LoginResponseDto> login(@Body() LoginRequestDto body);
}
