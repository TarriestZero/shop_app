// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get catalogTitle => 'Каталог';

  @override
  String get cartTitle => 'Корзина';

  @override
  String get emptyCart => 'Корзина пуста';

  @override
  String get checkoutTitle => 'Оформление заказа';

  @override
  String productTitle(String productId) {
    return 'Товар $productId';
  }

  @override
  String orderTitle(String orderId) {
    return 'Заказ $orderId';
  }

  @override
  String get orderConfirmationUnavailable => 'Подтверждение заказа недоступно';
}
