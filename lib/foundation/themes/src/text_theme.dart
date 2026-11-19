part of '../theme.dart';

/// Сопоставляет базовые текстовые стили с ролями Material.
TextTheme createAppTextTheme() {
  return const TextTheme(
    headlineLarge: AppBaseTextStyles.h1,
    headlineMedium: AppBaseTextStyles.h2,
    titleLarge: AppBaseTextStyles.h3,
    bodyLarge: AppBaseTextStyles.l,
    bodyMedium: AppBaseTextStyles.m,
    bodySmall: AppBaseTextStyles.s,
  );
}
