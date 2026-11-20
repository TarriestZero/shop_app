import 'app_exception.dart';

enum StorageErrorType { read, write }

/// Ошибка чтения или записи данных в локальное хранилище.
final class StorageException extends AppException {
  const StorageException.read()
    : type = StorageErrorType.read,
      super(code: 'storage_read');
  const StorageException.write()
    : type = StorageErrorType.write,
      super(code: 'storage_write');

  final StorageErrorType type;
}
