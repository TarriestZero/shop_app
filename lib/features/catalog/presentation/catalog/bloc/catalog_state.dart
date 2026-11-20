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

final class CatalogFiltersSelected extends CatalogState {
  const CatalogFiltersSelected(this.repository, this.filters);

  final CatalogFiltersRepository repository;
  final CatalogFilters filters;

  @override
  List<Object?> get props => [repository, filters];
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
  CatalogData(
    List<CatalogProduct> products, {
    this.isOffline = false,
    this.filters = const CatalogFilters.empty(),
    int? totalCount,
  }) : products = List.unmodifiable(products),
       totalCount = totalCount ?? products.length;

  final List<CatalogProduct> products;
  final bool isOffline;
  final CatalogFilters filters;
  final int totalCount;

  @override
  List<Object?> get props => [products, isOffline, filters, totalCount];
}

final class CatalogLoaded extends CatalogData {
  CatalogLoaded(
    super.products, {
    super.isOffline,
    super.filters,
    super.totalCount,
  });
}

final class CatalogEmpty extends CatalogLoaded {
  CatalogEmpty({super.filters, super.isOffline}) : super(const []);
}

final class CatalogRefreshing extends CatalogLoaded {
  CatalogRefreshing(
    super.products, {
    super.isOffline,
    super.filters,
    super.totalCount,
  });
}

final class CatalogRefreshFailure extends CatalogLoaded {
  CatalogRefreshFailure(
    super.products, {
    required this.exception,
    super.filters,
    super.totalCount,
  }) : super(
         isOffline:
             exception is NetworkException && exception.isConnectionError,
       );

  final AppException exception;

  @override
  List<Object?> get props => [...super.props, exception];
}
