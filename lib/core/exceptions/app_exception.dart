/// Базовый класс ожидаемых ошибок приложения.
abstract class AppException implements Exception {
  const AppException({this.message, this.code});

  /// Исходное сообщение для диагностики. Текст интерфейса берётся из локализации.
  final String? message;
  final String? code;

  @override
  String toString() => message ?? runtimeType.toString();
}
