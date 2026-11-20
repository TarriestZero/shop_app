import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/foundation/foundation.dart';

class CartTabIcon extends StatelessWidget {
  const CartTabIcon({super.key, this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartNotifierBloc, CartState, int>(
        selector: (state) => state.totalQuantity,
        builder: (context, quantity) => Badge(
          isLabelVisible: quantity > 0,
          label: Text('$quantity'),
          backgroundColor: context.colors.primary,
          textColor: context.colors.textPrimary,
          child: Icon(
            selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
          ),
        ),
      );
}
