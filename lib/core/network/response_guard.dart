import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shop_app/core/exceptions/index.dart';

/// Переводит ошибки Dio и разбора ответа в исключения приложения.
/// Сохраняет существующий [AppException] и исходный стек ошибки.
Future<T> guardNetwork<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } catch (error, stackTrace) {
    final mapped = switch (error) {
      DioException() => _mapDio(error),
      SocketException() => const NetworkException.noConnection(),
      TimeoutException() => const NetworkException.timeout(),
      HandshakeException() => const NetworkException.badCertificate(),
      FormatException() || TypeError() => const NetworkException.parse(),
      Exception() => NetworkException.custom(message: error.toString()),
      _ => null,
    };
    if (mapped == null) rethrow;
    Error.throwWithStackTrace(mapped, stackTrace);
  }
}

AppException _mapDio(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionError => const NetworkException.noConnection(),
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const NetworkException.timeout(),
    DioExceptionType.badResponse => _mapHttp(error.response),
    DioExceptionType.badCertificate => const NetworkException.badCertificate(),
    DioExceptionType.cancel => const NetworkException.cancelled(),
    DioExceptionType.transformTimeout => const NetworkException.parse(),
    DioExceptionType.unknown => switch (error.error) {
      SocketException() => const NetworkException.noConnection(),
      TimeoutException() => const NetworkException.timeout(),
      HandshakeException() => const NetworkException.badCertificate(),
      FormatException() || TypeError() => const NetworkException.parse(),
      _ => NetworkException.custom(message: error.error?.toString()),
    },
  };
}

AppException _mapHttp(Response<dynamic>? response) {
  final status = response?.statusCode;
  final message = _extractErrorMessage(response?.data);

  return switch (status) {
    400 ||
    422 => ValidationException(message: message, code: status.toString()),
    401 => const NetworkException.unauthorized(),
    403 => const NetworkException.forbidden(),
    404 => const NetworkException.notFound(),
    408 => const NetworkException.timeout(statusCode: 408),
    429 => const NetworkException.tooManyRequests(),
    final int status when status >= 500 && status <= 599 =>
      NetworkException.server(statusCode: status),
    _ => NetworkException.custom(message: message, statusCode: status),
  };
}

String? _extractErrorMessage(Object? error) {
  if (error is String) {
    final message = error.trim();
    return message.isEmpty || message.startsWith('<') ? null : message;
  }
  if (error is Map) {
    for (final key in const ['detail', 'message', 'title']) {
      final value = error[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  return null;
}
