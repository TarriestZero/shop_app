import 'package:dio/dio.dart';
import 'package:shop_app/core/exceptions/network_exception.dart';

/// Проверяет наличие обязательного JSON-ответа до разбора моделей Retrofit.
class EmptyResponseInterceptor extends Interceptor {
  /// Разрешает пустое тело для методов с nullable-результатом.
  static const allowEmptyResponse = 'allow_empty_response';

  /// Отклоняет ответ без данных; пустой JSON-массив остаётся успешным ответом.
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    final status = response.statusCode;
    final data = response.data;
    final empty = data == null || data is String && data.trim().isEmpty;
    if (status != null &&
        status >= 200 &&
        status <= 299 &&
        options.method != 'HEAD' &&
        options.responseType == ResponseType.json &&
        options.extra[allowEmptyResponse] != true &&
        empty) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: response,
          error: NetworkException.emptyResponse(statusCode: status),
        ),
      );
      return;
    }
    handler.next(response);
  }
}
