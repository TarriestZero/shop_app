part of 'catalog_cubit.dart';

sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

final class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

final class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

final class CatalogProductSelected extends CatalogState {
  const CatalogProductSelected(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class CatalogCartSelected extends CatalogState {
  const CatalogCartSelected();
}

final class CatalogLoadFailure extends CatalogState {
  const CatalogLoadFailure(this.exception);

  final AppException exception;

  bool get isOffline {
    final error = exception;
    return error is NetworkException && error.isConnectionError;
  }

  @override
  List<Object?> get props => [exception];
}

sealed class CatalogData extends CatalogState {
  CatalogData(List<CatalogProduct> products, {this.isOffline = false})
    : products = List.unmodifiable(products);

  final List<CatalogProduct> products;
  final bool isOffline;

  @override
  List<Object?> get props => [products, isOffline];
}

final class CatalogLoaded extends CatalogData {
  CatalogLoaded(super.products, {super.isOffline});
}

final class CatalogEmpty extends CatalogLoaded {
  CatalogEmpty() : super(const []);
}

final class CatalogRefreshing extends CatalogLoaded {
  CatalogRefreshing(super.products, {super.isOffline});
}

final class CatalogRefreshFailure extends CatalogLoaded {
  CatalogRefreshFailure(super.products, {required this.exception})
    : super(
        isOffline: exception is NetworkException && exception.isConnectionError,
      );

  final AppException exception;

  @override
  List<Object?> get props => [...super.props, exception];
}
