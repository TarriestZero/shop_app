import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';

import '../../support/cart_test_support.dart';

void main() {
  test('Новое хранилище возвращает пустую корзину без записи', () async {
    final preferences = MemoryCartPreferences();
    final items = await createCartRepository(preferences).load();
    final state = CartReady(items);

    expect(items, isEmpty);
    expect(state.totalQuantity, 0);
    expect(state.totalInCents, 0);
    expect(state.contains(cartProduct.productId), isFalse);
    expect(preferences.writes, 0);
  });

  test(
    'Сумма нескольких товаров пересчитывается после каждого изменения',
    () async {
      final repository = createCartRepository(MemoryCartPreferences());
      const other = CartItem(
        productId: 2,
        title: 'Второй товар',
        priceInCents: 1000,
        quantity: 3,
      );

      var state = CartReady(await repository.add(cartProduct.withQuantity(2)));
      expect(state.totalQuantity, 2);
      expect(state.totalInCents, 44950);

      state = CartReady(await repository.add(other));
      expect(state.items, [cartProduct.withQuantity(2), other]);
      expect(state.totalQuantity, 5);
      expect(state.totalInCents, 47950);

      state = CartReady(await repository.changeQuantity(1, 2));
      expect(state.quantityFor(1), 4);
      expect(state.quantityFor(2), 3);
      expect(state.totalQuantity, 7);
      expect(state.totalInCents, 92900);

      state = CartReady(await repository.changeQuantity(2, -2));
      expect(state.quantityFor(1), 4);
      expect(state.quantityFor(2), 1);
      expect(state.totalQuantity, 5);
      expect(state.totalInCents, 90900);

      state = CartReady(await repository.remove(1));
      expect(state.contains(1), isFalse);
      expect(state.items, [other.withQuantity(1)]);
      expect(state.totalQuantity, 1);
      expect(state.totalInCents, 1000);

      state = CartReady(await repository.changeQuantity(2, -1));
      expect(state.items, isEmpty);
      expect(state.totalQuantity, 0);
      expect(state.totalInCents, 0);
    },
  );

  test(
    'Отсутствующий товар и нулевое изменение не затрагивают корзину',
    () async {
      final preferences = MemoryCartPreferences();
      final repository = createCartRepository(preferences);
      await repository.add(cartProduct.withQuantity(2));
      final snapshot = preferences.snapshot;

      expect(await repository.remove(999), [cartProduct.withQuantity(2)]);
      expect(await repository.changeQuantity(999, 1), [
        cartProduct.withQuantity(2),
      ]);
      expect(await repository.changeQuantity(1, 0), [
        cartProduct.withQuantity(2),
      ]);
      expect(preferences.writes, 1);
      expect(preferences.snapshot, same(snapshot));
    },
  );

  for (final quantity in [0, -1]) {
    test(
      'Добавление с количеством $quantity отклоняется без изменения данных',
      () async {
        final preferences = MemoryCartPreferences();
        final repository = createCartRepository(preferences);
        await repository.add(cartProduct);
        final snapshot = preferences.snapshot;

        await expectLater(
          repository.add(cartProduct.withQuantity(quantity)),
          throwsArgumentError,
        );
        expect(await repository.load(), [cartProduct]);
        expect(preferences.writes, 1);
        expect(preferences.snapshot, same(snapshot));
      },
    );
  }

  test(
    'A restart restores merged quantities and the original product snapshot',
    () async {
      final preferences = MemoryCartPreferences();
      final repository = createCartRepository(preferences);
      await repository.add(cartProduct);
      await repository.add(
        const CartItem(
          productId: 1,
          title: 'Новое название',
          priceInCents: 1,
          quantity: 2,
        ),
      );
      final restored = await createCartRepository(preferences).load();

      expect(restored, [cartProduct.withQuantity(3)]);
      expect(restored.single.totalInCents, 67425);
      expect(() => restored.clear(), throwsUnsupportedError);
    },
  );

  test(
    'Concurrent mixed operations are serialized without losing increments',
    () async {
      final repository = createCartRepository(MemoryCartPreferences());
      await Future.wait([
        for (var i = 0; i < 10; i++) repository.add(cartProduct),
        for (var i = 0; i < 10; i++) repository.changeQuantity(1, 1),
        for (var i = 0; i < 5; i++) repository.changeQuantity(1, -1),
      ]);
      expect((await repository.load()).single.quantity, 15);
    },
  );

  test('Removing a product removes the whole group; decrementing to zero also removes it', () async {
    final repository = createCartRepository(MemoryCartPreferences());
    await repository.add(cartProduct.withQuantity(8));
    const other = CartItem(
      productId: 2,
      title: 'Другой товар',
      priceInCents: 1000,
      quantity: 1,
    );
    await repository.add(other);
    expect(await repository.remove(1), [other]);
    expect(await repository.changeQuantity(2, -1), isEmpty);
  });

  test('A failed write preserves memory and disk, and does not block later operations', () async {
    final preferences = MemoryCartPreferences();
    final repository = createCartRepository(preferences);
    await repository.add(cartProduct.withQuantity(2));
    final snapshot = preferences.snapshot;
    preferences.failWrites = true;
    await expectLater(repository.remove(1), throwsA(isA<StorageException>()));
    expect(preferences.snapshot, same(snapshot));
    expect(await repository.load(), [cartProduct.withQuantity(2)]);

    preferences.failWrites = false;
    await repository.changeQuantity(1, 1);
    expect(await createCartRepository(preferences).load(), [
      cartProduct.withQuantity(3),
    ]);
  });

  test(
    'Read errors and malformed snapshots prevent accidental overwriting',
    () async {
      final preferences = MemoryCartPreferences()..failReads = true;
      final repository = createCartRepository(preferences);
      await expectLater(
        repository.add(cartProduct),
        throwsA(
          isA<StorageException>().having(
            (error) => error.type,
            'type',
            StorageErrorType.read,
          ),
        ),
      );
      preferences.failReads = false;
      for (final json in [
        {'version': 2, 'items': []},
        {
          'version': 1,
          'items': [5],
        },
        {
          'version': 1,
          'items': [
            {
              'productId': 1,
              'title': 'Товар',
              'priceInCents': 100,
              'quantity': -1,
              'category': '',
            },
          ],
        },
      ]) {
        preferences.snapshot = json;
        await expectLater(
          repository.add(cartProduct),
          throwsA(isA<StorageException>()),
        );
        expect(preferences.snapshot, same(json));
      }
      expect(preferences.writes, 0);

      preferences.snapshot = null;
      expect(await repository.add(cartProduct), [cartProduct]);
    },
  );
}
