import 'app_exception.dart';

/// Ошибка проверки переданных данных, включая ответы HTTP 400 и 422.
final class ValidationException extends AppException {
  const ValidationException({super.message, this.field, super.code});

  final String? field;
}
