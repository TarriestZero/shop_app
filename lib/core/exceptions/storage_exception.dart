import 'app_exception.dart';

/// Ошибка записи данных в локальное хранилище.
final class StorageException extends AppException {
  const StorageException.write() : super(code: 'storage_write');
}
