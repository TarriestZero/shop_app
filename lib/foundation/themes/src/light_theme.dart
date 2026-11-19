part of '../theme.dart';

/// Создаёт светлую тему на основе общей палитры проекта.
ThemeData createAppLightTheme() {
  const colors = foundationLightColors;

  return ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: colors.primary,
      onPrimary: colors.textPrimary,
      secondary: colors.textSecondary,
      onSecondary: colors.surface,
      error: colors.error,
      onError: colors.surface,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.textSecondary,
      outlineVariant: colors.border,
      surfaceContainerLow: colors.appBackground,
      surfaceContainer: colors.appBackground,
      surfaceContainerHigh: colors.appBackground,
      surfaceContainerHighest: colors.appBackground,
      shadow: colors.textPrimary,
      scrim: colors.textPrimary,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.surface,
      inversePrimary: colors.primary,
      surfaceTint: Colors.transparent,
    ),
    scaffoldBackgroundColor: colors.appBackground,
    textTheme: createAppTextTheme().apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colors.textSecondary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: colors.textSecondary),
    ),
    dividerTheme: DividerThemeData(color: colors.border),
    extensions: const [colors],
  );
}
