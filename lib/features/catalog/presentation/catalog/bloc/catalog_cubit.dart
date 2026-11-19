import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';

part 'catalog_state.dart';

abstract interface class CatalogActions {
  Future<void> load();
  Future<void> refresh();
  void openProduct(int productId);
  void openCart();
  void setActive(bool active);
}

class CatalogCubit extends Cubit<CatalogState> implements CatalogActions {
  CatalogCubit(this._repository) : super(const CatalogInitial());

  final CatalogRepository _repository;
  Future<void>? _pendingLoad;
  Timer? _retryTimer;
  Duration _retryDelay = const Duration(seconds: 2);
  bool _active = true;

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
  void openCart() {
    if (isClosed) return;
    final current = state;
    emit(const CatalogCartSelected());
    emit(current);
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
        if (cached != null) _emitLoaded(cached);
      }

      final current = state;
      emit(
        current is CatalogLoaded
            ? CatalogRefreshing(current.products, isOffline: current.isOffline)
            : const CatalogLoading(),
      );

      final products = await _repository.loadCatalog();
      if (isClosed) return;
      _retryDelay = const Duration(seconds: 2);
      _emitLoaded(products);
    } on AppException catch (error) {
      if (isClosed) return;
      final current = state;
      if (current is CatalogLoaded) {
        emit(CatalogRefreshFailure(current.products, exception: error));
      } else {
        emit(CatalogLoadFailure(error));
      }
      if (error is NetworkException && error.isConnectionError) {
        _scheduleRetry();
      }
    }
  }

  void _emitLoaded(List<CatalogProduct> products) {
    emit(products.isEmpty ? CatalogEmpty() : CatalogLoaded(products));
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
  Future<void> close() {
    _retryTimer?.cancel();
    return super.close();
  }
}
