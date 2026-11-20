import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/presentation/catalog/bloc/catalog_cubit.dart';
import 'package:shop_app/features/catalog/presentation/catalog/widgets/catalog_product_card.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';

@RoutePage()
class CatalogScreen extends StatefulWidget implements AutoRouteWrapper {
  const CatalogScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (context) =>
        CatalogCubit(context.read<CatalogRepository>())..load(),
    child: this,
  );

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CatalogCubit>();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => cubit.setActive(true),
      onInactive: () => cubit.setActive(false),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.catalogTitle),
        actions: [
          IconButton(
            tooltip: strings.cartTitle,
            onPressed: context.read<CatalogCubit>().openCart,
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<CatalogCubit, CatalogState>(
          listenWhen: (previous, current) =>
              current is CatalogProductSelected ||
              current is CatalogCartSelected ||
              current is CatalogRefreshFailure && !current.isOffline,
          listener: (context, state) {
            switch (state) {
              case CatalogProductSelected():
                context.router.push(
                  ProductDetailsRoute(productId: state.productId.toString()),
                );
              case CatalogCartSelected():
                context.tabsRouter.navigate(const CartRoute());
              case CatalogRefreshFailure():
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      userErrorMessage(
                        state.exception,
                        strings,
                        fallback: strings.catalogRefreshFailed,
                      ),
                    ),
                  ),
                );
              default:
                break;
            }
          },
          buildWhen: (previous, current) =>
              current is! CatalogProductSelected &&
              current is! CatalogCartSelected,
          builder: (context, state) {
            if (state is CatalogLoaded) return _CatalogContent(state: state);
            if (state is CatalogLoadFailure) {
              final offline = state.isOffline;
              return _CatalogStatus(
                title: offline
                    ? strings.noConnection
                    : userErrorMessage(
                        state.exception,
                        strings,
                        fallback: strings.catalogLoadFailed,
                      ),
                description: offline ? strings.catalogNeedsConnection : null,
                onRetry: context.read<CatalogCubit>().refresh,
              );
            }
            return Center(
              child: CircularProgressIndicator(
                semanticsLabel: strings.catalogLoading,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({required this.state});

  final CatalogLoaded state;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Column(
      children: [
        if (state.isOffline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 18,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(strings.noConnection)),
              ],
            ),
          ),
        SizedBox(
          height: 2,
          child: state is CatalogRefreshing
              ? const LinearProgressIndicator(minHeight: 2)
              : null,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: context.read<CatalogCubit>().refresh,
            child: state.products.isEmpty
                ? _CatalogStatus(title: strings.catalogEmpty)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          childAspectRatio: 0.6,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return CatalogProductCard(
                        key: ValueKey(product.id),
                        product: product,
                        onTap: () => context.read<CatalogCubit>().openProduct(
                          product.id,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _CatalogStatus extends StatelessWidget {
  const _CatalogStatus({required this.title, this.description, this.onRetry});

  final String title;
  final String? description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                    if (onRetry != null) ...[
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: onRetry,
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
