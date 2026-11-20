import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// No description provided for @catalogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Каталог'**
  String get catalogTitle;

  /// No description provided for @catalogLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка каталога'**
  String get catalogLoading;

  /// No description provided for @catalogEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В каталоге пока нет товаров'**
  String get catalogEmpty;

  /// No description provided for @catalogLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить каталог'**
  String get catalogLoadFailed;

  /// No description provided for @catalogRefreshFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить каталог'**
  String get catalogRefreshFailed;

  /// No description provided for @catalogNoFilterResults.
  ///
  /// In ru, this message translates to:
  /// **'Нет товаров с такими фильтрами'**
  String get catalogNoFilterResults;

  /// No description provided for @filtersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filtersTitle;

  /// No description provided for @filtersReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get filtersReset;

  /// No description provided for @filtersApply.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get filtersApply;

  /// No description provided for @filtersCounting.
  ///
  /// In ru, this message translates to:
  /// **'Подсчёт результатов'**
  String get filtersCounting;

  /// No description provided for @filtersCountFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подсчитать результаты. Попробуйте ещё раз.'**
  String get filtersCountFailed;

  /// No description provided for @filtersShowResults.
  ///
  /// In ru, this message translates to:
  /// **'Показать: {count}'**
  String filtersShowResults(int count);

  /// No description provided for @filtersCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get filtersCategories;

  /// No description provided for @filtersNoCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категорий пока нет'**
  String get filtersNoCategories;

  /// No description provided for @filtersPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get filtersPrice;

  /// No description provided for @filtersPriceRange.
  ///
  /// In ru, this message translates to:
  /// **'От {minimum} до {maximum}'**
  String filtersPriceRange(String minimum, String maximum);

  /// No description provided for @noConnection.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения'**
  String get noConnection;

  /// No description provided for @catalogNeedsConnection.
  ///
  /// In ru, this message translates to:
  /// **'Подключитесь к интернету, чтобы загрузить каталог.'**
  String get catalogNeedsConnection;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @requestTimedOut.
  ///
  /// In ru, this message translates to:
  /// **'Истекло время ожидания ответа. Попробуйте ещё раз.'**
  String get requestTimedOut;

  /// No description provided for @authenticationRequired.
  ///
  /// In ru, this message translates to:
  /// **'Необходимо войти в аккаунт'**
  String get authenticationRequired;

  /// No description provided for @accessDenied.
  ///
  /// In ru, this message translates to:
  /// **'Доступ запрещён'**
  String get accessDenied;

  /// No description provided for @resourceNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Запрашиваемые данные не найдены'**
  String get resourceNotFound;

  /// No description provided for @serverError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера. Попробуйте позже.'**
  String get serverError;

  /// No description provided for @tooManyRequests.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много запросов. Попробуйте позже.'**
  String get tooManyRequests;

  /// No description provided for @invalidServerResponse.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обработать данные сервера'**
  String get invalidServerResponse;

  /// No description provided for @requestCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Запрос отменён'**
  String get requestCancelled;

  /// No description provided for @secureConnectionFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось установить защищённое соединение'**
  String get secureConnectionFailed;

  /// No description provided for @storageWriteFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить данные на устройстве'**
  String get storageWriteFailed;

  /// No description provided for @validationFailed.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте введённые данные и попробуйте ещё раз.'**
  String get validationFailed;

  /// No description provided for @cartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Корзина'**
  String get cartTitle;

  /// No description provided for @emptyCart.
  ///
  /// In ru, this message translates to:
  /// **'Корзина пуста'**
  String get emptyCart;

  /// No description provided for @checkoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оформление заказа'**
  String get checkoutTitle;

  /// No description provided for @productTitle.
  ///
  /// In ru, this message translates to:
  /// **'Товар {productId}'**
  String productTitle(String productId);

  /// No description provided for @orderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ {orderId}'**
  String orderTitle(String orderId);

  /// No description provided for @orderConfirmationUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение заказа недоступно'**
  String get orderConfirmationUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
