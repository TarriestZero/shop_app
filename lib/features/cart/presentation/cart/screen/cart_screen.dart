import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/l10n/app_localizations.dart';

@RoutePage()
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.cartTitle)),
      body: Center(child: Text(strings.emptyCart)),
    );
  }
}
