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
  String get catalogLoading => 'Загрузка каталога';

  @override
  String get catalogEmpty => 'В каталоге пока нет товаров';

  @override
  String get catalogLoadFailed => 'Не удалось загрузить каталог';

  @override
  String get catalogRefreshFailed => 'Не удалось обновить каталог';

  @override
  String get catalogNoFilterResults => 'Нет товаров с такими фильтрами';

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String get filtersReset => 'Сбросить';

  @override
  String get filtersApply => 'Показать';

  @override
  String get filtersCounting => 'Подсчёт результатов';

  @override
  String get filtersCountFailed =>
      'Не удалось подсчитать результаты. Попробуйте ещё раз.';

  @override
  String filtersShowResults(int count) {
    return 'Показать: $count';
  }

  @override
  String get filtersCategories => 'Категории';

  @override
  String get filtersNoCategories => 'Категорий пока нет';

  @override
  String get filtersPrice => 'Цена';

  @override
  String filtersPriceRange(String minimum, String maximum) {
    return 'От $minimum до $maximum';
  }

  @override
  String get noConnection => 'Нет соединения';

  @override
  String get catalogNeedsConnection =>
      'Подключитесь к интернету, чтобы загрузить каталог.';

  @override
  String get retry => 'Повторить';

  @override
  String get requestTimedOut =>
      'Истекло время ожидания ответа. Попробуйте ещё раз.';

  @override
  String get authenticationRequired => 'Необходимо войти в аккаунт';

  @override
  String get accessDenied => 'Доступ запрещён';

  @override
  String get resourceNotFound => 'Запрашиваемые данные не найдены';

  @override
  String get serverError => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get tooManyRequests => 'Слишком много запросов. Попробуйте позже.';

  @override
  String get invalidServerResponse => 'Не удалось обработать данные сервера';

  @override
  String get requestCancelled => 'Запрос отменён';

  @override
  String get secureConnectionFailed =>
      'Не удалось установить защищённое соединение';

  @override
  String get storageWriteFailed => 'Не удалось сохранить данные на устройстве';

  @override
  String get validationFailed =>
      'Проверьте введённые данные и попробуйте ещё раз.';

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
