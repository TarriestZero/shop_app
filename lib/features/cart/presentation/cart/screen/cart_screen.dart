import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/core/network/network_connection_service.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/presentation/cart/widgets/cart_item_card.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/checkout/presentation/checkout/bloc/checkout_connection_cubit.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

@RoutePage()
class CartScreen extends StatelessWidget implements AutoRouteWrapper {
  const CartScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (context) => CheckoutConnectionCubit(
      context.read<CatalogRepository>(),
      connectionChanges: context.read<NetworkConnectionService>().watch(),
    ),
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.cartTitle)),
      body: SafeArea(
        top: false,
        child: BlocBuilder<CartNotifierBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoadFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userErrorMessage(
                          state.exception,
                          strings,
                          fallback: strings.cartLoadFailed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        onPressed: () => context.read<CartNotifierBloc>().add(
                          const CartStarted(),
                        ),
                        label: strings.retry,
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is! CartData) {
              return Center(
                child: CircularProgressIndicator(
                  semanticsLabel: strings.cartLoading,
                ),
              );
            }
            if (state.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.emptyCart),
                      const SizedBox(height: 16),
                      AppButton(
                        label: strings.goToCatalog,
                        onPressed: () =>
                            context.router.navigate(const CatalogRoute()),
                      ),
                    ],
                  ),
                ),
              );
            }

            final formatter = NumberFormat.simpleCurrency(
              locale: strings.localeName,
              name: 'USD',
            );
            return Column(
              children: [
                SizedBox(
                  height: 2,
                  child: state is CartSaving
                      ? const LinearProgressIndicator(minHeight: 2)
                      : null,
                ),
                Expanded(
                  child: BlocBuilder<CheckoutConnectionCubit, bool>(
                    buildWhen: (previous, current) => !previous && current,
                    builder: (context, connected) => ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, thickness: 1),
                      itemBuilder: (context, index) => CartItemCard(
                        key: ValueKey(state.items[index].productId),
                        item: state.items[index],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border(
                      top: BorderSide(color: context.colors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text(
                            strings.cartTotal,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            formatter.format(state.totalInCents / 100),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<CheckoutConnectionCubit, bool>(
                        builder: (context, connected) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!connected) ...[
                              Text(strings.checkoutNeedsConnection),
                              const SizedBox(height: 12),
                            ],
                            AppButton(
                              onPressed: state is CartSaving || !connected
                                  ? null
                                  : () {
                                      if (context
                                          .read<CheckoutConnectionCubit>()
                                          .state) {
                                        context.router.push(
                                          const CheckoutRoute(),
                                        );
                                      }
                                    },
                              label: strings.cartCheckout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
