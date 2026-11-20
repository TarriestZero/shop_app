import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/filters/domain/repository/filters_repository.dart';

part 'filters_state.dart';

abstract interface class FiltersActions<T> {
  Future<void> load();
  Future<void> update(T filters);
  Future<void> reset();
  void apply();
}

/// Хранит черновик фильтров и актуальное количество подходящих элементов.
class FiltersController<T> extends Cubit<FiltersState<T>>
    implements FiltersActions<T> {
  FiltersController({
    required this._repository,
    required T initialFilters,
    required this._defaultFilters,
  }) : super(FiltersInitial(initialFilters)) {
    _subscription = _repository.changes.listen((_) => unawaited(load()));
  }

  final FiltersRepository<T> _repository;
  final T _defaultFilters;
  late final StreamSubscription<void> _subscription;
  int _revision = 0;

  /// Повторно подсчитывает результаты для текущего черновика.
  @override
  Future<void> load() => update(state.filters);

  /// Меняет черновик. Результаты предыдущих запросов игнорируются.
  @override
  Future<void> update(T filters) async {
    if (isClosed) return;
    final revision = ++_revision;
    emit(FiltersLoading(filters));
    try {
      final count = await _repository.count(filters);
      if (isClosed || revision != _revision) return;
      emit(FiltersReady(filters, count));
    } on AppException catch (error) {
      if (isClosed || revision != _revision) return;
      emit(FiltersFailure(filters, error));
    }
  }

  /// Сбрасывает черновик к значениям по умолчанию и пересчитывает результаты.
  @override
  Future<void> reset() => update(_defaultFilters);

  /// Подтверждает черновик только после успешного подсчёта.
  @override
  void apply() {
    if (isClosed) return;
    final current = state;
    if (current is! FiltersReady<T> || current is FiltersApplied<T>) return;
    emit(FiltersApplied(current.filters, current.count));
  }

  @override
  Future<void> close() async {
    final closing = super.close();
    await _subscription.cancel();
    await closing;
  }
}
