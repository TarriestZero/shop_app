import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/l10n/app_localizations.dart';

/// Показывает ошибки общей корзины на любом маршруте, включая прямую ссылку.
class CartFeedbackListener extends StatelessWidget {
  const CartFeedbackListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocListener<CartNotifierBloc, CartState>(
        listenWhen: (previous, current) => current is CartUpdateFailure,
        listener: (context, state) {
          if (state is! CartUpdateFailure) return;
          final strings = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userErrorMessage(
                  state.exception,
                  strings,
                  fallback: strings.cartUpdateFailed,
                ),
              ),
            ),
          );
        },
        child: child,
      );
}
