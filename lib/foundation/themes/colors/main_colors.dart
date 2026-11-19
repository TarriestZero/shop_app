import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/res/colors.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'main_colors.tailor.dart';

/// Цвета интерфейса по назначению.
@TailorMixin(themeGetter: ThemeGetter.onBuildContextProps)
class FoundationColors extends ThemeExtension<FoundationColors>
    with _$FoundationColorsTailorMixin {
  const FoundationColors({
    required this.primary,
    required this.appBackground,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.success,
  });

  @override
  final Color primary;
  @override
  final Color appBackground;
  @override
  final Color surface;
  @override
  final Color textPrimary;
  @override
  final Color textSecondary;
  @override
  final Color border;
  @override
  final Color error;
  @override
  final Color success;
}

const foundationLightColors = FoundationColors(
  primary: AppBaseColors.brand,
  appBackground: AppBaseColors.grey,
  surface: AppBaseColors.white,
  textPrimary: AppBaseColors.black,
  textSecondary: AppBaseColors.brown,
  border: AppBaseColors.greyDark,
  error: AppBaseColors.error,
  success: AppBaseColors.success,
);

extension FoundationColorsBuildContext on BuildContext {
  /// Возвращает цвета foundation из текущей темы.
  FoundationColors get colors => foundationColors;
}
