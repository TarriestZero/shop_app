import 'package:shop_app/l10n/app_localizations.dart';

import 'index.dart';

/// Выбирает текст ожидаемой ошибки из общей локализации приложения.
String userErrorMessage(
  AppException error,
  AppLocalizations strings, {
  required String fallback,
}) {
  if (error is NetworkException) {
    return switch (error.type) {
      NetworkErrorType.noConnection => strings.noConnection,
      NetworkErrorType.timeout => strings.requestTimedOut,
      NetworkErrorType.unauthorized => strings.authenticationRequired,
      NetworkErrorType.forbidden => strings.accessDenied,
      NetworkErrorType.notFound => strings.resourceNotFound,
      NetworkErrorType.server => strings.serverError,
      NetworkErrorType.tooManyRequests => strings.tooManyRequests,
      NetworkErrorType.invalidResponse => strings.invalidServerResponse,
      NetworkErrorType.cancelled => strings.requestCancelled,
      NetworkErrorType.badCertificate => strings.secureConnectionFailed,
      NetworkErrorType.custom => fallback,
    };
  }
  if (error is StorageException) return strings.storageWriteFailed;
  if (error is ValidationException) return strings.validationFailed;
  return fallback;
}
