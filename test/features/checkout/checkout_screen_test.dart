import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/network/network_connection_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/presentation/widgets/cart_feedback_listener.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/presentation/catalog/screen/catalog_screen.dart';
import 'package:shop_app/features/checkout/presentation/checkout/screen/checkout_screen.dart';
import 'package:shop_app/features/checkout/presentation/order_confirmation/screen/order_confirmation_screen.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

import '../../support/cart_test_support.dart';
import '../../support/catalog_test_support.dart';
import '../../support/network_test_support.dart';

void main() {
  testWidgets('Редактирование поля не показывает ошибки нетронутых полей', (
    tester,
  ) async {
    await _pumpCheckout(tester);
    expect(find.text('Обязательное поле'), findsNothing);
    await _enter(tester, 0, 'Анна');
    expect(find.text('Обязательное поле'), findsNothing);
    expect(_submitButton(tester).onPressed, isNull);

    await _enter(tester, 0, '');
    expect(find.text('Обязательное поле'), findsNothing);
    await tester.tap(find.byType(TextFormField).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Обязательное поле'), findsOneWidget);
    final fields = tester
        .stateList<FormFieldState<String>>(find.byType(TextFormField))
        .toList();
    expect(fields[0].errorText, 'Обязательное поле');
    expect(fields.skip(1).every((field) => field.errorText == null), isTrue);
  });

  testWidgets(
    'Ошибка пустого поля исчезает при исправлении без проверки других полей',
    (tester) async {
      await _pumpCheckout(tester);
      await tester.tap(find.byType(TextFormField).at(0));
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Обязательное поле'), findsOneWidget);
      await _enter(tester, 0, 'Анна');
      expect(find.text('Обязательное поле'), findsNothing);
      expect(_submitButton(tester).onPressed, isNull);
    },
  );

  testWidgets('Попытка отправки с клавиатуры проверяет все обязательные поля', (
    tester,
  ) async {
    final app = await _pumpCheckout(tester);
    final address = find.byType(TextFormField).at(3);
    await tester.ensureVisible(address);
    await tester.tap(address);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Обязательное поле'), findsNWidgets(4));
    expect(find.byType(OrderConfirmationScreen), findsNothing);
    expect(app.cart.state.quantityFor(1), 2);
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets(
    'Form показывает ошибки под полями и включает кнопку только для валидных данных',
    (tester) async {
      await _pumpCheckout(tester);
      expect(
        tester.widget<Form>(find.byType(Form)).key,
        isA<GlobalKey<FormState>>(),
      );
      expect(_submitButton(tester).onPressed, isNull);
      await _enter(tester, 0, 'Анна');
      await _enter(tester, 1, 'wrong');
      await _enter(tester, 2, '12345');
      await _enter(tester, 3, '   ');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Введите корректный email'), findsOneWidget);
      expect(find.text('Введите не менее 10 цифр'), findsOneWidget);
      expect(find.text('Обязательное поле'), findsOneWidget);
      expect(_submitButton(tester).onPressed, isNull);

      await _enter(tester, 1, 'anna@example.com');
      await _enter(tester, 2, '+7 (999) 123-45-67');
      await _enter(tester, 3, 'Москва, ул. Мира, 10');
      expect(_submitButton(tester).onPressed, isNotNull);
      expect(find.text('Введите корректный email'), findsNothing);
    },
  );

  testWidgets(
    'Оформление показывает номер, очищает корзину и возвращает в каталог',
    (tester) async {
      final app = await _pumpCheckout(tester);
      await _fillValid(tester);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Оформить'));
      await tester.tap(find.widgetWithText(FilledButton, 'Оформить'));
      await tester.pumpAndSettle();

      final success = tester.widget<OrderConfirmationScreen>(
        find.byType(OrderConfirmationScreen),
      );
      expect(success.orderId, matches(RegExp(r'^\d+$')));
      expect(find.text('Заказ оформлен'), findsOneWidget);
      expect(find.text('Заказ ${success.orderId}'), findsOneWidget);
      expect(find.byType(CheckoutScreen), findsNothing);
      expect(app.cart.state.items, isEmpty);
      expect(await createCartRepository(app.preferences).load(), isEmpty);
      expect(app.router.stack.map((page) => page.name), [
        OrderConfirmationRoute.name,
      ]);

      await tester.tap(find.text('Вернуться в каталог'));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogScreen), findsOneWidget);
      expect(app.router.stack.map((page) => page.name), [MainRoute.name]);
      expect(app.router.canPop(), isFalse);
    },
  );

  testWidgets(
    'Ошибка записи сохраняет форму и товары, повтор завершает заказ',
    (tester) async {
      final app = await _pumpCheckout(tester);
      await _fillValid(tester);
      final snapshot = app.preferences.snapshot;
      app.preferences.failWrites = true;
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Оформить'));
      await tester.tap(find.widgetWithText(FilledButton, 'Оформить'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderConfirmationScreen), findsNothing);
      expect(
        find.text('Не удалось оформить заказ. Попробуйте ещё раз.'),
        findsOneWidget,
      );
      expect(app.cart.state.quantityFor(1), 2);
      expect(app.preferences.snapshot, same(snapshot));
      final fields = tester
          .widgetList<AppTextField>(find.byType(AppTextField))
          .toList();
      expect(fields.map((field) => field.controller.text), [
        'Анна',
        'anna@example.com',
        '+7 (999) 123-45-67',
        'Москва, ул. Мира, 10',
      ]);
      expect(_submitButton(tester).onPressed, isNotNull);

      app.preferences.failWrites = false;
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Оформить'));
      await tester.tap(find.widgetWithText(FilledButton, 'Оформить'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderConfirmationScreen), findsOneWidget);
      expect(app.cart.state.items, isEmpty);
    },
  );

  testWidgets('Во время записи повторное нажатие и возврат заблокированы', (
    tester,
  ) async {
    final app = await _pumpCheckout(tester, path: '/cart');
    await tester.tap(find.widgetWithText(FilledButton, 'К оформлению'));
    await tester.pumpAndSettle();
    expect(app.router.stack.map((page) => page.name), [
      MainRoute.name,
      CheckoutRoute.name,
    ]);
    await _fillValid(tester);
    final pending = Completer<void>();
    app.preferences.beforeWrite = () => pending.future;
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Оформить'));
    await tester.tap(find.widgetWithText(FilledButton, 'Оформить'));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Оформляем…'))
          .onPressed,
      isNull,
    );
    expect(app.cart.state.quantityFor(1), 2);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(CheckoutScreen), findsOneWidget);

    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(OrderConfirmationScreen), findsOneWidget);
    expect(app.preferences.writes, 2);
  });

  testWidgets('Пустая корзина не создаёт заказ', (tester) async {
    final app = await _pumpCheckout(tester, seed: false);
    expect(find.text('Корзина пуста'), findsOneWidget);
    expect(find.byType(Form), findsNothing);
    expect(find.text('Оформить'), findsNothing);
    expect(app.preferences.writes, 0);
  });

  testWidgets('Узкий экран и клавиатура не вызывают переполнения формы', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(() {
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.view.resetViewInsets();
    });
    await _pumpCheckout(tester, size: const Size(320, 780));
    await _fillValid(tester);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Оформить'));
    await tester.pumpAndSettle();
    expect(_submitButton(tester).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}

FilledButton _submitButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Оформить'));

Future<void> _enter(WidgetTester tester, int index, String value) async {
  final field = find.byType(TextFormField).at(index);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _fillValid(WidgetTester tester) async {
  await _enter(tester, 0, 'Анна');
  await _enter(tester, 1, 'anna@example.com');
  await _enter(tester, 2, '+7 (999) 123-45-67');
  await _enter(tester, 3, 'Москва, ул. Мира, 10');
}

Future<
  ({CartNotifierBloc cart, AppRouter router, MemoryCartPreferences preferences})
>
_pumpCheckout(
  WidgetTester tester, {
  bool seed = true,
  String path = '/checkout',
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  final preferences = MemoryCartPreferences();
  final cartRepository = createCartRepository(preferences);
  if (seed) await cartRepository.add(cartProduct.withQuantity(2));
  final cart = CartNotifierBloc(cartRepository)..add(const CartStarted());
  final repository = CatalogRepository(
    CatalogTestClient(),
    cache: CatalogTestCache(),
  );
  final router = AppRouter();
  final config = router.config(
    deepLinkBuilder: (_) => DeepLink.path(path, includePrefixMatches: false),
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await cart.close();
    await repository.close();
    router.dispose();
    await tester.binding.setSurfaceSize(null);
  });
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CatalogRepository>.value(value: repository),
        RepositoryProvider<NetworkConnectionService>.value(
          value: TestNetworkConnectionService(),
        ),
      ],
      child: BlocProvider.value(
        value: cart,
        child: MaterialApp.router(
          theme: createAppLightTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              CartFeedbackListener(child: child ?? const SizedBox.shrink()),
          routerConfig: RouterConfig<Object>(
            routeInformationProvider: config.routeInformationProvider,
            routeInformationParser: config.routeInformationParser,
            routerDelegate: config.routerDelegate,
            backButtonDispatcher: config.backButtonDispatcher,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (cart: cart, router: router, preferences: preferences);
}
