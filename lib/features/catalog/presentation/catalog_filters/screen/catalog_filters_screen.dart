import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_filters_repository.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_filters.dart';
import 'package:shop_app/features/catalog/presentation/catalog_filters/widgets/catalog_filter_fields.dart';
import 'package:shop_app/features/filters/presentation/filters/bloc/filters_controller.dart';
import 'package:shop_app/features/filters/presentation/filters/screen/filters_screen.dart';

@RoutePage()
class CatalogFiltersScreen extends StatefulWidget {
  const CatalogFiltersScreen({
    super.key,
    required this.repository,
    required this.filters,
  });

  final CatalogFiltersRepository repository;
  final CatalogFilters filters;

  @override
  State<CatalogFiltersScreen> createState() => _CatalogFiltersScreenState();
}

class _CatalogFiltersScreenState extends State<CatalogFiltersScreen> {
  late final FiltersController<CatalogFilters> _controller;

  @override
  void initState() {
    super.initState();
    _controller = FiltersController(
      repository: widget.repository,
      initialFilters: widget.filters,
      defaultFilters: const CatalogFilters.empty(),
    )..load();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FiltersScreen<CatalogFilters>(
    controller: _controller,
    onApply: (filters) => context.router.maybePop(filters),
    filtersBuilder: (context, filters) {
      final products = widget.repository.products;
      final categories = {
        ...products
            .map((product) => product.category.trim())
            .where((category) => category.isNotEmpty),
        ...filters.categories,
      }.toList()..sort();
      final maximumPrice = products.fold(
        max(filters.minimumPriceInCents ?? 0, filters.maximumPriceInCents ?? 0),
        (price, product) => max(price, product.priceInCents),
      );
      return CatalogFilterFields(
        filters: filters,
        categories: categories,
        maximumPriceInCents: maximumPrice,
        onChanged: _controller.update,
      );
    },
  );
}
