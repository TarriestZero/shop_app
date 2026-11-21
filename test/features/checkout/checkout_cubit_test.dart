import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/features/checkout/presentation/checkout/bloc/checkout_cubit.dart';

void main() {
  blocTest<CheckoutCubit, CheckoutState>(
    'Успех выдаёт локальный номер после сохранения пустой корзины',
    build: () => CheckoutCubit(
      clearCart: () async => true,
      createOrderId: () => 'LOCAL-42',
    ),
    act: (cubit) => cubit.submit(),
    expect: () => [
      const CheckoutSubmitting(),
      const CheckoutSuccess('LOCAL-42'),
    ],
  );

  test('Отказ очистки не создаёт номер заказа и допускает повтор', () async {
    var allowed = false;
    var generated = 0;
    final cubit = CheckoutCubit(
      clearCart: () async => allowed,
      createOrderId: () => '${++generated}',
    );
    addTearDown(cubit.close);
    await cubit.submit();
    expect(cubit.state, const CheckoutFailure());
    expect(generated, 0);

    allowed = true;
    await cubit.submit();
    expect(cubit.state, const CheckoutSuccess('1'));
    expect(generated, 1);
  });

  test(
    'Параллельное нажатие и повтор после успеха не создают второй заказ',
    () async {
      final pending = Completer<bool>();
      var clears = 0;
      var generated = 0;
      final cubit = CheckoutCubit(
        clearCart: () {
          clears++;
          return pending.future;
        },
        createOrderId: () => '${++generated}',
      );
      addTearDown(cubit.close);
      final first = cubit.submit();
      await cubit.submit();
      expect(cubit.state, const CheckoutSubmitting());
      expect(clears, 1);
      expect(generated, 0);

      pending.complete(true);
      await first;
      await cubit.submit();
      expect(cubit.state, const CheckoutSuccess('1'));
      expect(clears, 1);
      expect(generated, 1);
    },
  );

  test(
    'Завершение команды после закрытия страницы не публикует успех',
    () async {
      final pending = Completer<bool>();
      var generated = 0;
      final cubit = CheckoutCubit(
        clearCart: () => pending.future,
        createOrderId: () => '${++generated}',
      );
      final submitting = cubit.submit();
      await cubit.close();
      pending.complete(true);
      await expectLater(submitting, completes);
      expect(generated, 0);
    },
  );
}
