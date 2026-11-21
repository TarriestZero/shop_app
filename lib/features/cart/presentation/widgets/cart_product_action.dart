import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';
import 'package:shop_app/features/cart/presentation/widgets/cart_quantity_control.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

/// Показывает добавление товара либо его количество из общего notifier.
/// Оба состояния занимают одну область, сохраняя расположение элементов карточки.
class CartProductAction extends StatelessWidget {
  const CartProductAction({
    super.key,
    required this.item,
    this.showLabel = false,
  });

  final CartItem item;
  final bool showLabel;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartNotifierBloc, CartState, (bool, bool, bool)>(
        selector: (state) => (
          state.contains(item.productId),
          state is CartData,
          state is CartLoadFailure,
        ),
        builder: (context, status) {
          final strings = AppLocalizations.of(context)!;
          final label = status.$3 ? strings.retry : strings.cartAddProduct;
          final VoidCallback? onPressed = status.$2
              ? () =>
                    context.read<CartNotifierBloc>().add(CartProductAdded(item))
              : status.$3
              ? () => context.read<CartNotifierBloc>().add(const CartStarted())
              : null;
          final icon = Icon(
            status.$3 ? Icons.refresh : Icons.add_shopping_cart,
          );
          return IndexedStack(
            index: status.$1 ? 1 : 0,
            alignment: Alignment.centerRight,
            children: [
              if (showLabel)
                AppButton(onPressed: onPressed, icon: icon, label: label)
              else
                AppButton.icon(
                  filled: true,
                  tooltip: label,
                  onPressed: onPressed,
                  icon: icon,
                ),
              CartQuantityControl(productId: item.productId),
            ],
          );
        },
      );
}
