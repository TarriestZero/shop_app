import 'package:material_ui/material_ui.dart';

/// Базовые размеры и начертания текста с гарнитурой из темы приложения.
abstract final class AppBaseTextStyles {
  static const h1 = TextStyle(
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w500,
  );

  static const h2 = TextStyle(
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w500,
  );

  static const h3 = TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w500,
  );

  static const l = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w400,
  );

  static const m = TextStyle(
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w400,
  );

  static const s = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );
}
