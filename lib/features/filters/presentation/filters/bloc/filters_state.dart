part of 'filters_controller.dart';

sealed class FiltersState<T> extends Equatable {
  const FiltersState(this.filters);

  final T filters;

  /// Количество результатов известно только после успешного подсчёта.
  int? get count => null;

  @override
  List<Object?> get props => [filters];
}

final class FiltersInitial<T> extends FiltersState<T> {
  const FiltersInitial(super.filters);
}

final class FiltersLoading<T> extends FiltersState<T> {
  const FiltersLoading(super.filters);
}

final class FiltersReady<T> extends FiltersState<T> {
  const FiltersReady(super.filters, this.count);

  @override
  final int count;

  @override
  List<Object?> get props => [...super.props, count];
}

final class FiltersFailure<T> extends FiltersState<T> {
  const FiltersFailure(super.filters, this.exception);

  final AppException exception;

  @override
  List<Object?> get props => [...super.props, exception];
}

final class FiltersApplied<T> extends FiltersReady<T> {
  const FiltersApplied(super.filters, super.count);
}
