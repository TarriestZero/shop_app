import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

@RoutePage()
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    @PathParam('orderId') required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.checkoutTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 48).clamp(
                  0,
                  double.infinity,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: context.colors.success,
                      size: 72,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.checkoutSuccess,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.orderTitle(orderId),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: strings.returnToCatalog,
                      onPressed: () => context.router.replaceAll([
                        const MainRoute(children: [CatalogRoute()]),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
