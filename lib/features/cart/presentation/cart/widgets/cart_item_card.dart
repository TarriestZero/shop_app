import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';
import 'package:shop_app/features/cart/presentation/widgets/cart_quantity_control.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

/// Карточка позиции. Свайп удаляет все единицы товара после успешного сохранения.
class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final formatter = NumberFormat.simpleCurrency(
      locale: strings.localeName,
      name: 'USD',
    );

    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.horizontal,
      confirmDismiss: (_) =>
          context.read<CartNotifierBloc>().removeProduct(item.productId),
      background: _DeleteBackground(alignment: Alignment.centerLeft),
      secondaryBackground: _DeleteBackground(alignment: Alignment.centerRight),
      child: Material(
        color: colors.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 140,
                child: AppProductImage(imageUrl: item.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    if (item.category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.category,
                        style: text.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      strings.cartArticle(item.productId),
                      style: text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatter.format(item.totalInCents / 100),
                      style: text.titleLarge,
                    ),
                    Text(
                      strings.cartUnitPrice(
                        formatter.format(item.priceInCents / 100),
                      ),
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CartQuantityControl(productId: item.productId),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    padding: const EdgeInsets.all(20),
    color: context.colors.error,
    child: Icon(
      Icons.delete_outline,
      color: context.colors.surface,
      semanticLabel: AppLocalizations.of(context)!.cartRemoveProduct,
    ),
  );
}
