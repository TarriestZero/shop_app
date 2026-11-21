import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/catalog/presentation/product_details/bloc/product_details_cubit.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

class ProductDetailsContent extends StatelessWidget {
  const ProductDetailsContent({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final ProductDetailsLoaded state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final product = state.product;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
            child: state is ProductDetailsRefreshing
                ? const LinearProgressIndicator(minHeight: 2)
                : null,
          ),
          ColoredBox(
            color: colors.surface,
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppProductImage(imageUrl: product.imageUrl),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(product.title, style: text.headlineMedium),
                if (product.category.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    product.category,
                    style: text.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  strings.cartArticle(product.id),
                  style: text.bodySmall?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.rating == null
                            ? strings.productNoRating
                            : strings.productRating(
                                NumberFormat(
                                  '0.#',
                                  strings.localeName,
                                ).format(product.rating),
                                product.ratingCount ?? 0,
                              ),
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(strings.productDescription, style: text.titleLarge),
                const SizedBox(height: 12),
                Text(
                  product.description.trim().isEmpty
                      ? strings.productNoDescription
                      : product.description,
                  style: text.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
