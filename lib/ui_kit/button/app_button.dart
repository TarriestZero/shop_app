import 'package:material_ui/material_ui.dart';

enum _AppButtonVariant { filled, text }

/// Общая кнопка проекта. `null` в onPressed или isLoading блокируют нажатие.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required String this._label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.filled,
       _iconOnly = false,
       tooltip = null,
       color = null,
       visualDensity = null;

  /// Текстовая кнопка для вторичных действий.
  const AppButton.text({
    super.key,
    required String this._label,
    required this.onPressed,
  }) : _variant = _AppButtonVariant.text,
       _iconOnly = false,
       icon = null,
       isLoading = false,
       tooltip = null,
       color = null,
       visualDensity = null;

  /// Кнопка с одной иконкой и обязательной подписью для доступности.
  const AppButton.icon({
    super.key,
    required Widget this.icon,
    required String this.tooltip,
    required this.onPressed,
    bool filled = false,
    this.color,
    this.visualDensity,
  }) : _label = null,
       _variant = filled ? _AppButtonVariant.filled : _AppButtonVariant.text,
       _iconOnly = true,
       isLoading = false;

  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final String? tooltip;
  final Color? color;
  final VisualDensity? visualDensity;
  final String? _label;
  final _AppButtonVariant _variant;
  final bool _iconOnly;

  @override
  Widget build(BuildContext context) {
    final onPressed = isLoading ? null : this.onPressed;
    if (_iconOnly) {
      return _variant == _AppButtonVariant.filled
          ? IconButton.filled(
              onPressed: onPressed,
              icon: icon!,
              tooltip: tooltip,
              color: color,
              visualDensity: visualDensity,
            )
          : IconButton(
              onPressed: onPressed,
              icon: icon!,
              tooltip: tooltip,
              color: color,
              visualDensity: visualDensity,
            );
    }
    final label = Text(_label!);
    if (_variant == _AppButtonVariant.text) {
      return TextButton(onPressed: onPressed, child: label);
    }
    final leading = isLoading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon;
    return leading == null
        ? FilledButton(onPressed: onPressed, child: label)
        : FilledButton.icon(onPressed: onPressed, icon: leading, label: label);
  }
}
