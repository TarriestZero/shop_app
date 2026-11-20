import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

/// Подписывается только на количество своего товара в глобальной корзине.
class CartQuantityControl extends StatelessWidget {
  const CartQuantityControl({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartNotifierBloc, CartState, (int, bool)>(
        selector: (state) => (
          state.quantityFor(productId),
          state is CartData && state.contains(productId),
        ),
        builder: (context, value) => AppQuantityStepper(
          quantity: value.$1,
          onDecrease: value.$2
              ? () => context.read<CartNotifierBloc>().add(
                  CartQuantityDecreased(productId),
                )
              : null,
          onIncrease: value.$2
              ? () => context.read<CartNotifierBloc>().add(
                  CartQuantityIncreased(productId),
                )
              : null,
        ),
      );
}
