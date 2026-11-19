import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/l10n/app_localizations.dart';

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
      appBar: AppBar(title: Text(strings.orderTitle(orderId))),
      body: Center(child: Text(strings.orderConfirmationUnavailable)),
    );
  }
}
