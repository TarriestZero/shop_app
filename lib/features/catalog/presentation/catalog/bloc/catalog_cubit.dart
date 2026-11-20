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
  CatalogCubit(this._repository) : super(const CatalogInitial()) {
    _subscription = _repository.changes.listen((products) {
      if (!isClosed) _setProducts(products);
    });
  }

  final CatalogRepository _repository;
  late final StreamSubscription<List<CatalogProduct>> _subscription;
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

      final products = await _repository.loadCatalog();
      if (isClosed) return;
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
            filters: current.filters,
            totalCount: current.totalCount,
          ),
        );
      } else {
        emit(CatalogLoadFailure(error));
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

  void _emitFiltered({bool isOffline = false}) {
    emit(
      _allProducts.isEmpty
          ? CatalogEmpty(filters: _filters, isOffline: isOffline)
          : CatalogLoaded(
              _filtersRepository.filter(_filters),
              isOffline: isOffline,
              filters: _filters,
              totalCount: _allProducts.length,
            ),
    );
  }

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
      _retryTimer?.cancel();
    }
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    final closing = super.close();
    await _subscription.cancel();
    await _filtersRepository.close();
    await closing;
  }
}
