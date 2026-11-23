import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/core/exceptions/network_exception.dart';
import 'package:shop_app/core/network/network_connection_service.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_filters.dart';
import 'package:shop_app/features/catalog/presentation/catalog/bloc/catalog_cubit.dart';
import 'package:shop_app/features/catalog/presentation/catalog/widgets/catalog_product_card.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

@RoutePage()
class CatalogScreen extends StatefulWidget implements AutoRouteWrapper {
  const CatalogScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (context) => CatalogCubit(
      context.read<CatalogRepository>(),
      connectionChanges: context.read<NetworkConnectionService>().watch(),
    )..load(),
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
          BlocBuilder<CatalogCubit, CatalogState>(
            buildWhen: (previous, current) =>
                current is! CatalogFiltersSelected &&
                current is! CatalogProductSelected,
            builder: (context, state) => AppButton.icon(
              tooltip: strings.filtersTitle,
              onPressed: state is CatalogLoaded
                  ? context.read<CatalogCubit>().openFilters
                  : null,
              icon: Badge(
                isLabelVisible:
                    state is CatalogLoaded && !state.filters.isEmpty,
                backgroundColor: context.colors.primary,
                child: const Icon(Icons.tune),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<CatalogCubit, CatalogState>(
          listenWhen: (previous, current) => switch (current) {
            CatalogProductSelected() || CatalogFiltersSelected() => true,
            CatalogRefreshFailure(
              exception: NetworkException(type: NetworkErrorType.noConnection),
            ) =>
              false,
            CatalogRefreshFailure() => true,
            _ => false,
          },
          listener: (context, state) async {
            switch (state) {
              case CatalogProductSelected():
                context.router.push(
                  ProductDetailsRoute(productId: state.productId.toString()),
                );
              case CatalogFiltersSelected():
                final filters = await context.router.push<CatalogFilters>(
                  CatalogFiltersRoute(
                    repository: state.repository,
                    filters: state.filters,
                  ),
                );
                if (context.mounted && filters != null) {
                  context.read<CatalogCubit>().applyFilters(filters);
                }
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
                    action: SnackBarAction(
                      label: strings.retry,
                      onPressed: () => context.read<CatalogCubit>().refresh(),
                    ),
                  ),
                );
              default:
                break;
            }
          },
          buildWhen: (previous, current) =>
              current is! CatalogProductSelected &&
              current is! CatalogFiltersSelected,
          builder: (context, state) {
            if (state is CatalogLoaded) return _CatalogContent(state: state);
            if (state is CatalogLoadFailure) {
              final offline = state.isOffline;
              return _CatalogStatus(
                title: userErrorMessage(
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
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

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
                AppButton.text(
                  onPressed: context.read<CatalogCubit>().refresh,
                  label: strings.retry,
                ),
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
                ? _CatalogStatus(
                    title: state.totalCount == 0
                        ? strings.catalogEmpty
                        : strings.catalogNoFilterResults,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240 * textScale,
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
                      AppButton(
                        onPressed: onRetry,
                        label: AppLocalizations.of(context)!.retry,
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
