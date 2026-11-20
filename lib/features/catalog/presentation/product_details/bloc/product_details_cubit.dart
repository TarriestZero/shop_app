import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';

part 'product_details_state.dart';

abstract interface class ProductDetailsActions {
  Future<void> load();
  Future<void> refresh();
  void openCart();
}

/// Показывает товар из общего снимка каталога и следит за его обновлениями.
class ProductDetailsCubit extends Cubit<ProductDetailsState>
    implements ProductDetailsActions {
  ProductDetailsCubit(this._repository, {required String productId})
    : _productId = int.tryParse(productId),
      super(const ProductDetailsInitial()) {
    _subscription = _repository.changes.listen(_setProduct);
  }

  final CatalogRepository _repository;
  final int? _productId;
  late final StreamSubscription<List<CatalogProduct>> _subscription;
  Future<void>? _pendingLoad;

  /// Читает память или кеш. При отсутствии снимка загружает полный каталог.
  @override
  Future<void> load() => _runLoad(refresh: false);

  /// Обновляет общий каталог, сохраняя товар на экране до завершения запроса.
  @override
  Future<void> refresh() => _runLoad(refresh: true);

  @override
  void openCart() {
    if (isClosed) return;
    final current = state;
    emit(const ProductDetailsCartSelected());
    emit(current);
  }

  Future<void> _runLoad({required bool refresh}) {
    if (isClosed) return Future.value();
    if (_pendingLoad != null) return _pendingLoad!;
    if (_productId == null) {
      emit(const ProductDetailsUnavailable());
      return Future.value();
    }
    return _pendingLoad = _load(refresh: refresh).whenComplete(() {
      _pendingLoad = null;
    });
  }

  Future<void> _load({required bool refresh}) async {
    try {
      if (!refresh) {
        final memory = _repository.snapshot;
        if (memory != null) {
          _setProduct(memory);
          return;
        }
        emit(const ProductDetailsLoading());
        final cached = await _repository.getCachedCatalog();
        if (isClosed) return;
        if (cached != null) {
          _setProduct(cached);
          return;
        }
      }

      final current = state;
      emit(
        current is ProductDetailsLoaded
            ? ProductDetailsRefreshing(
                current.product,
                isOffline: current.isOffline,
              )
            : const ProductDetailsLoading(),
      );
      final products = await _repository.loadCatalog();
      if (isClosed) return;
      _setProduct(products);
    } on AppException catch (error) {
      if (isClosed) return;
      final current = state;
      emit(
        current is ProductDetailsLoaded
            ? ProductDetailsRefreshFailure(current.product, error)
            : ProductDetailsLoadFailure(error),
      );
    }
  }

  void _setProduct(List<CatalogProduct> products) {
    if (isClosed || _productId == null) return;
    for (final product in products) {
      if (product.id == _productId) {
        emit(ProductDetailsLoaded(product));
        return;
      }
    }
    emit(const ProductDetailsUnavailable());
  }

  @override
  Future<void> close() async {
    final closing = super.close();
    await _subscription.cancel();
    await closing;
  }
}
