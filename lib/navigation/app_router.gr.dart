// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CartScreen]
class CartRoute extends PageRouteInfo<void> {
  const CartRoute({List<PageRouteInfo>? children})
    : super(CartRoute.name, initialChildren: children);

  static const String name = 'CartRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CartScreen();
    },
  );
}

/// generated route for
/// [CatalogFiltersScreen]
class CatalogFiltersRoute extends PageRouteInfo<CatalogFiltersRouteArgs> {
  CatalogFiltersRoute({
    Key? key,
    required CatalogFiltersRepository repository,
    required CatalogFilters filters,
    List<PageRouteInfo>? children,
  }) : super(
         CatalogFiltersRoute.name,
         args: CatalogFiltersRouteArgs(
           key: key,
           repository: repository,
           filters: filters,
         ),
         initialChildren: children,
       );

  static const String name = 'CatalogFiltersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CatalogFiltersRouteArgs>();
      return CatalogFiltersScreen(
        key: args.key,
        repository: args.repository,
        filters: args.filters,
      );
    },
  );
}

class CatalogFiltersRouteArgs {
  const CatalogFiltersRouteArgs({
    this.key,
    required this.repository,
    required this.filters,
  });

  final Key? key;

  final CatalogFiltersRepository repository;

  final CatalogFilters filters;

  @override
  String toString() {
    return 'CatalogFiltersRouteArgs{key: $key, repository: $repository, filters: $filters}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CatalogFiltersRouteArgs) return false;
    return key == other.key &&
        repository == other.repository &&
        filters == other.filters;
  }

  @override
  int get hashCode => key.hashCode ^ repository.hashCode ^ filters.hashCode;
}

/// generated route for
/// [CatalogScreen]
class CatalogRoute extends PageRouteInfo<void> {
  const CatalogRoute({List<PageRouteInfo>? children})
    : super(CatalogRoute.name, initialChildren: children);

  static const String name = 'CatalogRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const CatalogScreen());
    },
  );
}

/// generated route for
/// [CheckoutScreen]
class CheckoutRoute extends PageRouteInfo<void> {
  const CheckoutRoute({List<PageRouteInfo>? children})
    : super(CheckoutRoute.name, initialChildren: children);

  static const String name = 'CheckoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CheckoutScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [OrderConfirmationScreen]
class OrderConfirmationRoute extends PageRouteInfo<OrderConfirmationRouteArgs> {
  OrderConfirmationRoute({
    Key? key,
    required String orderId,
    List<PageRouteInfo>? children,
  }) : super(
         OrderConfirmationRoute.name,
         args: OrderConfirmationRouteArgs(key: key, orderId: orderId),
         rawPathParams: {'orderId': orderId},
         initialChildren: children,
       );

  static const String name = 'OrderConfirmationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OrderConfirmationRouteArgs>(
        orElse: () => OrderConfirmationRouteArgs(
          orderId: pathParams.getString('orderId'),
        ),
      );
      return OrderConfirmationScreen(key: args.key, orderId: args.orderId);
    },
  );
}

class OrderConfirmationRouteArgs {
  const OrderConfirmationRouteArgs({this.key, required this.orderId});

  final Key? key;

  final String orderId;

  @override
  String toString() {
    return 'OrderConfirmationRouteArgs{key: $key, orderId: $orderId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrderConfirmationRouteArgs) return false;
    return key == other.key && orderId == other.orderId;
  }

  @override
  int get hashCode => key.hashCode ^ orderId.hashCode;
}

/// generated route for
/// [ProductDetailsScreen]
class ProductDetailsRoute extends PageRouteInfo<ProductDetailsRouteArgs> {
  ProductDetailsRoute({
    Key? key,
    required String productId,
    List<PageRouteInfo>? children,
  }) : super(
         ProductDetailsRoute.name,
         args: ProductDetailsRouteArgs(key: key, productId: productId),
         rawPathParams: {'productId': productId},
         initialChildren: children,
       );

  static const String name = 'ProductDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProductDetailsRouteArgs>(
        orElse: () => ProductDetailsRouteArgs(
          productId: pathParams.getString('productId'),
        ),
      );
      return ProductDetailsScreen(key: args.key, productId: args.productId);
    },
  );
}

class ProductDetailsRouteArgs {
  const ProductDetailsRouteArgs({this.key, required this.productId});

  final Key? key;

  final String productId;

  @override
  String toString() {
    return 'ProductDetailsRouteArgs{key: $key, productId: $productId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProductDetailsRouteArgs) return false;
    return key == other.key && productId == other.productId;
  }

  @override
  int get hashCode => key.hashCode ^ productId.hashCode;
}
