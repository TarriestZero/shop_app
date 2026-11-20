import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/features/cart/presentation/widgets/cart_tab_icon.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/presentation/product_details/bloc/product_details_cubit.dart';
import 'package:shop_app/features/catalog/presentation/product_details/widgets/product_details_cart_bar.dart';
import 'package:shop_app/features/catalog/presentation/product_details/widgets/product_details_content.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';

@RoutePage()
class ProductDetailsScreen extends StatelessWidget implements AutoRouteWrapper {
  const ProductDetailsScreen({
    super.key,
    @PathParam('productId') required this.productId,
  });

  final String productId;

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (context) => ProductDetailsCubit(
      context.read<CatalogRepository>(),
      productId: productId,
    )..load(),
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
      listenWhen: (previous, current) =>
          current is ProductDetailsCartSelected ||
          current is ProductDetailsRefreshFailure && !current.isOffline,
      listener: (context, state) {
        if (state is ProductDetailsCartSelected) {
          context.router.navigate(const MainRoute(children: [CartRoute()]));
        } else if (state is ProductDetailsRefreshFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userErrorMessage(
                  state.exception,
                  strings,
                  fallback: strings.productRefreshFailed,
                ),
              ),
            ),
          );
        }
      },
      buildWhen: (previous, current) => current is! ProductDetailsCartSelected,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(strings.productDetailsTitle),
          actions: [
            IconButton(
              tooltip: strings.cartTitle,
              onPressed: context.read<ProductDetailsCubit>().openCart,
              icon: const CartTabIcon(),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: switch (state) {
            ProductDetailsLoaded() => ProductDetailsContent(
              state: state,
              onRefresh: context.read<ProductDetailsCubit>().refresh,
            ),
            ProductDetailsUnavailable() => _ProductStatus(
              title: strings.productUnavailable,
              description: strings.productUnavailableDescription,
              onRetry: context.read<ProductDetailsCubit>().refresh,
            ),
            ProductDetailsLoadFailure() => _ProductStatus(
              title: userErrorMessage(
                state.exception,
                strings,
                fallback: strings.productLoadFailed,
              ),
              description: state.isOffline
                  ? strings.productNeedsConnection
                  : null,
              onRetry: context.read<ProductDetailsCubit>().refresh,
            ),
            _ => Center(
              child: CircularProgressIndicator(
                semanticsLabel: strings.productLoading,
              ),
            ),
          },
        ),
        bottomNavigationBar: state is ProductDetailsLoaded
            ? ProductDetailsCartBar(product: state.product)
            : null,
      ),
    );
  }
}

class _ProductStatus extends StatelessWidget {
  const _ProductStatus({
    required this.title,
    required this.onRetry,
    this.description,
  });

  final String title;
  final String? description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(description!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
