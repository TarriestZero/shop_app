import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_filters.dart';
import 'package:shop_app/l10n/app_localizations.dart';

class CatalogFilterFields extends StatelessWidget {
  const CatalogFilterFields({
    super.key,
    required this.filters,
    required this.categories,
    required this.maximumPriceInCents,
    required this.onChanged,
  });

  final CatalogFilters filters;
  final List<String> categories;
  final int maximumPriceInCents;
  final ValueChanged<CatalogFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final formatter = NumberFormat.simpleCurrency(
      locale: strings.localeName,
      name: 'USD',
    );
    final minimum = filters.minimumPriceInCents ?? 0;
    final maximum = filters.maximumPriceInCents ?? maximumPriceInCents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.filtersCategories, style: text.titleMedium),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          Text(strings.filtersNoCategories)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                FilterChip(
                  label: Text(category),
                  selected: filters.categories.contains(category),
                  onSelected: (selected) {
                    final categories = {...filters.categories};
                    selected
                        ? categories.add(category)
                        : categories.remove(category);
                    onChanged(
                      CatalogFilters(
                        categories: categories,
                        minimumPriceInCents: filters.minimumPriceInCents,
                        maximumPriceInCents: filters.maximumPriceInCents,
                      ),
                    );
                  },
                ),
            ],
          ),
        const SizedBox(height: 24),
        Text(strings.filtersPrice, style: text.titleMedium),
        const SizedBox(height: 12),
        Text(
          strings.filtersPriceRange(
            formatter.format(minimum / 100),
            formatter.format(maximum / 100),
          ),
        ),
        RangeSlider(
          min: 0,
          max: maximumPriceInCents.toDouble(),
          values: RangeValues(minimum.toDouble(), maximum.toDouble()),
          semanticFormatterCallback: (value) => formatter.format(value / 100),
          labels: RangeLabels(
            formatter.format(minimum / 100),
            formatter.format(maximum / 100),
          ),
          onChanged: maximumPriceInCents == 0
              ? null
              : (values) => onChanged(
                  CatalogFilters(
                    categories: filters.categories,
                    minimumPriceInCents: values.start.round() == 0
                        ? null
                        : values.start.round(),
                    maximumPriceInCents:
                        values.end.round() == maximumPriceInCents
                        ? null
                        : values.end.round(),
                  ),
                ),
        ),
      ],
    );
  }
}
