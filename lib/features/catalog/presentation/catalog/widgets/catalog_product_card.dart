import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';

/// Прямоугольная карточка товара для сетки каталога.
class CatalogProductCard extends StatelessWidget {
  const CatalogProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final CatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final price = NumberFormat.simpleCurrency(
      locale: AppLocalizations.of(context)!.localeName,
      name: 'USD',
    ).format(product.priceInCents / 100);
    final placeholder = Center(
      child: Icon(Icons.image_outlined, size: 40, color: colors.border),
    );
    final imageUrl = product.imageUrl;
    final category = product.category.trim();

    return Semantics(
      button: true,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? placeholder
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          loadingBuilder: (context, child, progress) =>
                              progress == null ? child : placeholder,
                          errorBuilder: (context, error, stackTrace) =>
                              placeholder,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
