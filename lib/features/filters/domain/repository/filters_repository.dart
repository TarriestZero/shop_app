/// Подсчёт результатов фильтрации для конкретной фичи.
abstract class FiltersRepository<T> {
  const FiltersRepository();

  /// Сообщает об изменениях исходных данных, требующих нового подсчёта.
  Stream<void> get changes => const Stream.empty();

  /// Возвращает количество подходящих элементов или выбрасывает AppException.
  Future<int> count(T filters);
}
