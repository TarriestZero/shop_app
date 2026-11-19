import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app/navigation/app_paths.dart';
import 'package:shop_app/src/features/cart/presentation/cart/screen/cart_screen.dart';
import 'package:shop_app/src/features/catalog/presentation/catalog/screen/catalog_screen.dart';
import 'package:shop_app/src/features/catalog/presentation/product_details/screen/product_details_screen.dart';
import 'package:shop_app/src/features/checkout/presentation/checkout/screen/checkout_screen.dart';
import 'package:shop_app/src/features/checkout/presentation/order_confirmation/screen/order_confirmation_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Screen,Route',
  generateForDir: ['lib/src/features'],
)
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: AppPaths.catalog, page: CatalogRoute.page, initial: true),
    AutoRoute(path: AppPaths.productDetails, page: ProductDetailsRoute.page),
    AutoRoute(path: AppPaths.cart, page: CartRoute.page),
    AutoRoute(path: AppPaths.checkout, page: CheckoutRoute.page),
    AutoRoute(
      path: AppPaths.orderConfirmation,
      page: OrderConfirmationRoute.page,
    ),
    RedirectRoute(path: AppPaths.wildcard, redirectTo: AppPaths.catalog),
  ];
}
