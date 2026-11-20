import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';

/// Компактный счётчик количества с кнопками уменьшения и увеличения.
class AppQuantityStepper extends StatelessWidget {
  const AppQuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = context.colors;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.surface,
        shape: StadiumBorder(side: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: strings.cartDecreaseQuantity,
            visualDensity: VisualDensity.compact,
            onPressed: onDecrease,
            color: colors.primary,
            icon: const Icon(Icons.remove),
          ),
          Flexible(
            child: Text(
              '$quantity',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              semanticsLabel: strings.cartQuantity(quantity),
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: colors.textPrimary),
            ),
          ),
          IconButton(
            tooltip: strings.cartIncreaseQuantity,
            visualDensity: VisualDensity.compact,
            onPressed: onIncrease,
            color: colors.primary,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
