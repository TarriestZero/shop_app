import 'app_exception.dart';

enum NetworkErrorType {
  noConnection,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  client,
  server,
  tooManyRequests,
  invalidResponse,
  emptyResponse,
  cancelled,
  badCertificate,
  custom,
}

/// Ошибка подключения, HTTP-запроса или обработки ответа API.
final class NetworkException extends AppException {
  const NetworkException._(this.type, {super.message, this.statusCode});

  const NetworkException.noConnection() : this._(NetworkErrorType.noConnection);

  const NetworkException.timeout({int? statusCode})
    : this._(NetworkErrorType.timeout, statusCode: statusCode);

  const NetworkException.unauthorized()
    : this._(NetworkErrorType.unauthorized, statusCode: 401);

  const NetworkException.forbidden()
    : this._(NetworkErrorType.forbidden, statusCode: 403);

  const NetworkException.notFound()
    : this._(NetworkErrorType.notFound, statusCode: 404);

  const NetworkException.client({required int statusCode, String? message})
    : this._(NetworkErrorType.client, statusCode: statusCode, message: message);

  const NetworkException.server({required int statusCode})
    : this._(NetworkErrorType.server, statusCode: statusCode);

  const NetworkException.tooManyRequests()
    : this._(NetworkErrorType.tooManyRequests, statusCode: 429);

  const NetworkException.parse() : this._(NetworkErrorType.invalidResponse);

  const NetworkException.emptyResponse({int? statusCode})
    : this._(NetworkErrorType.emptyResponse, statusCode: statusCode);

  const NetworkException.cancelled() : this._(NetworkErrorType.cancelled);

  const NetworkException.badCertificate()
    : this._(NetworkErrorType.badCertificate);

  const NetworkException.custom({String? message, int? statusCode})
    : this._(NetworkErrorType.custom, message: message, statusCode: statusCode);

  final NetworkErrorType type;
  final int? statusCode;

  /// Показывает, что запрос завершился ошибкой соединения до HTTP-ответа.
  bool get isConnectionError =>
      type == NetworkErrorType.noConnection ||
      type == NetworkErrorType.timeout && statusCode == null;
}
