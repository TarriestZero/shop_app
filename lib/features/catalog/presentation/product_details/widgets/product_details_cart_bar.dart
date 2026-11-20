import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';
import 'package:shop_app/features/cart/presentation/widgets/cart_product_action.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';

class ProductDetailsCartBar extends StatelessWidget {
  const ProductDetailsCartBar({super.key, required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final price = NumberFormat.simpleCurrency(
      locale: strings.localeName,
      name: 'USD',
    ).format(product.priceInCents / 100);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Text(price, style: Theme.of(context).textTheme.titleLarge),
              CartProductAction(
                showLabel: true,
                item: CartItem(
                  productId: product.id,
                  title: product.title,
                  priceInCents: product.priceInCents,
                  quantity: 1,
                  category: product.category,
                  imageUrl: product.imageUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
