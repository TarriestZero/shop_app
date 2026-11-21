part of 'product_details_cubit.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsUnavailable extends ProductDetailsState {
  const ProductDetailsUnavailable();
}

final class ProductDetailsCartSelected extends ProductDetailsState {
  const ProductDetailsCartSelected();
}

final class ProductDetailsLoadFailure extends ProductDetailsState {
  const ProductDetailsLoadFailure(this.exception);

  final AppException exception;

  bool get isOffline {
    final error = exception;
    return error is NetworkException &&
        error.type == NetworkErrorType.noConnection;
  }

  @override
  List<Object?> get props => [exception];
}

final class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(this.product, {this.isOffline = false});

  final CatalogProduct product;
  final bool isOffline;

  @override
  List<Object?> get props => [product, isOffline];
}

final class ProductDetailsRefreshing extends ProductDetailsLoaded {
  const ProductDetailsRefreshing(super.product, {super.isOffline});
}

final class ProductDetailsRefreshFailure extends ProductDetailsLoaded {
  ProductDetailsRefreshFailure(super.product, this.exception)
    : super(
        isOffline:
            exception is NetworkException &&
            exception.type == NetworkErrorType.noConnection,
      );

  final AppException exception;

  @override
  List<Object?> get props => [...super.props, exception];
}
