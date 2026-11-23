import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_filters_repository.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_filters.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';

part 'catalog_state.dart';

abstract interface class CatalogActions {
  Future<void> load();
  Future<void> refresh();
  void openProduct(int productId);
  void openFilters();
  void applyFilters(CatalogFilters filters);
  void setActive(bool active);
}

class CatalogCubit extends Cubit<CatalogState> implements CatalogActions {
  CatalogCubit(this._repository, {Stream<bool>? connectionChanges})
    : super(const CatalogInitial()) {
    _subscription = _repository.changes.listen((products) {
      final current = state;
      final offline = _hasConnection == false || _repository.isOffline;
      if (!isClosed &&
          (!identical(products, _lastSnapshot) ||
              current is CatalogLoaded && current.isOffline != offline)) {
        _setProducts(products);
      }
    });
    _connectionSubscription = connectionChanges?.listen(
      _onConnectionChanged,
      // При недоступном наблюдении за интерфейсами остаются HTTP и автоповторы.
      onError: (Object _) {},
    );
  }

  final CatalogRepository _repository;
  late final StreamSubscription<List<CatalogProduct>> _subscription;
  late final StreamSubscription<bool>? _connectionSubscription;
  bool? _hasConnection;
  int _connectionVersion = 0;
  bool _refreshOnReconnect = false;
  List<CatalogProduct>? _lastSnapshot;
  Future<void>? _pendingLoad;
  Timer? _retryTimer;
  Duration _retryDelay = const Duration(seconds: 2);
  bool _active = true;
  final _filtersRepository = CatalogFiltersRepository(const []);
  List<CatalogProduct> get _allProducts => _filtersRepository.products;
  CatalogFilters _filters = const CatalogFilters.empty();

  @override
  Future<void> load() => _runLoad(readCache: true);

  @override
  Future<void> refresh() => _runLoad(readCache: false);

  @override
  void openProduct(int productId) {
    if (isClosed) return;
    final current = state;
    emit(CatalogProductSelected(productId));
    emit(current);
  }

  @override
  void openFilters() {
    if (isClosed) return;
    final current = state;
    if (current is! CatalogLoaded) return;
    emit(CatalogFiltersSelected(_filtersRepository, _filters));
    emit(current);
  }

  @override
  void applyFilters(CatalogFilters filters) {
    if (isClosed) return;
    final current = state;
    if (current is! CatalogLoaded) return;
    _filters = filters;
    final products = _filtersRepository.filter(filters);
    if (current is CatalogRefreshing) {
      emit(
        CatalogRefreshing(
          products,
          isOffline: current.isOffline,
          filters: filters,
          totalCount: _allProducts.length,
        ),
      );
    } else if (current is CatalogRefreshFailure) {
      emit(
        CatalogRefreshFailure(
          products,
          exception: current.exception,
          isOffline: current.isOffline,
          filters: filters,
          totalCount: _allProducts.length,
        ),
      );
    } else {
      _emitFiltered(isOffline: current.isOffline);
    }
  }

  Future<void> _runLoad({required bool readCache}) {
    if (isClosed) return Future.value();
    if (_pendingLoad != null) return _pendingLoad!;

    _retryTimer?.cancel();
    return _pendingLoad = _load(readCache: readCache).whenComplete(() {
      _pendingLoad = null;
      if (_refreshOnReconnect && _active && !isClosed) {
        _refreshOnReconnect = false;
        unawaited(refresh());
      }
    });
  }

  Future<void> _load({required bool readCache}) async {
    try {
      if (readCache) {
        emit(const CatalogLoading());
        final cached = await _repository.getCachedCatalog();
        if (isClosed) return;
        if (cached != null) _setProducts(cached);
      }

      final current = state;
      emit(
        current is CatalogLoaded
            ? CatalogRefreshing(
                current.products,
                isOffline: current.isOffline,
                filters: current.filters,
                totalCount: current.totalCount,
              )
            : const CatalogLoading(),
      );

      final connectionVersion = _connectionVersion;
      final products = await _repository.loadCatalog();
      if (isClosed) return;
      // Успешный HTTP-ответ уточняет устаревший статус после возврата в приложение.
      // Событие потери сети, пришедшее во время запроса, сохраняет приоритет.
      if (connectionVersion == _connectionVersion) _hasConnection = true;
      _retryDelay = const Duration(seconds: 2);
      _setProducts(products);
    } on AppException catch (error) {
      if (isClosed) return;
      final current = state;
      if (current is CatalogLoaded) {
        emit(
          CatalogRefreshFailure(
            current.products,
            exception: error,
            isOffline:
                _hasConnection == false ||
                _repository.isOffline ||
                _isNoConnection(error),
            filters: current.filters,
            totalCount: current.totalCount,
          ),
        );
      } else {
        emit(
          CatalogLoadFailure(
            error,
            isOffline:
                _hasConnection == false ||
                _repository.isOffline ||
                _isNoConnection(error),
          ),
        );
      }
      if (error is NetworkException && error.isConnectionError) {
        _scheduleRetry();
      }
    }
  }

  void _setProducts(List<CatalogProduct> products) {
    if (!identical(products, _lastSnapshot)) {
      _lastSnapshot = products;
      _filtersRepository.updateProducts(products);
    }
    _emitFiltered();
  }

  void _emitFiltered({bool? isOffline}) {
    final offline =
        isOffline ?? (_hasConnection == false || _repository.isOffline);
    emit(
      _allProducts.isEmpty
          ? CatalogEmpty(filters: _filters, isOffline: offline)
          : CatalogLoaded(
              _filtersRepository.filter(_filters),
              isOffline: offline,
              filters: _filters,
              totalCount: _allProducts.length,
            ),
    );
  }

  void _onConnectionChanged(bool connected) {
    if (isClosed || _hasConnection == connected) return;
    final previous = _hasConnection;
    _hasConnection = connected;
    _connectionVersion++;
    if (!connected) {
      _refreshOnReconnect = false;
      _retryTimer?.cancel();
      final current = state;
      if (current is CatalogLoaded) {
        emit(
          CatalogRefreshFailure(
            current.products,
            exception: const NetworkException.noConnection(),
            filters: current.filters,
            totalCount: current.totalCount,
          ),
        );
      } else if (current is CatalogLoadFailure) {
        emit(const CatalogLoadFailure(NetworkException.noConnection()));
      }
    } else if (_active && previous == false) {
      _retryDelay = const Duration(seconds: 2);
      _retryTimer?.cancel();
      if (_pendingLoad != null) {
        // Запрос, начатый до восстановления сети, может завершиться старой ошибкой.
        _refreshOnReconnect = true;
      } else {
        unawaited(refresh());
      }
    }
  }

  static bool _isNoConnection(AppException error) =>
      error is NetworkException && error.type == NetworkErrorType.noConnection;

  void _scheduleRetry() {
    if (!_active) return;
    _retryTimer = Timer(_retryDelay, () => unawaited(refresh()));
    _retryDelay = Duration(seconds: min(_retryDelay.inSeconds * 2, 30));
  }

  @override
  void setActive(bool active) {
    if (isClosed || _active == active) return;
    _active = active;
    if (active) {
      unawaited(refresh());
    } else {
      _refreshOnReconnect = false;
      _retryTimer?.cancel();
    }
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    final closing = super.close();
    await _subscription.cancel();
    await _connectionSubscription?.cancel();
    await _filtersRepository.close();
    await closing;
  }
}
