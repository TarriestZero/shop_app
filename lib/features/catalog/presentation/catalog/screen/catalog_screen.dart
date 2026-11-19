import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';

@RoutePage()
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.catalogTitle),
        actions: [
          IconButton(
            tooltip: strings.cartTitle,
            onPressed: () => context.router.push(const CartRoute()),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
    );
  }
}
