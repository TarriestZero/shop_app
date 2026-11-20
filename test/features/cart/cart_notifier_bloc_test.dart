import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/cart/data/repositories/cart_repository.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';

import '../../support/cart_test_support.dart';

void main() {
  group('Загрузка состояния корзины из подставного репозитория', () {
    late _LoadRepository repository;
    const other = CartItem(
      productId: 2,
      title: 'Второй товар',
      priceInCents: 1000,
      quantity: 3,
    );

    setUp(() => repository = _LoadRepository());

    blocTest<CartNotifierBloc, CartState>(
      'Успешная загрузка публикует товары и правильные итоги',
      setUp: () => repository.items = [cartProduct.withQuantity(2), other],
      build: () => CartNotifierBloc(repository),
      act: (bloc) => bloc.add(const CartStarted()),
      expect: () => [
        const CartLoading(),
        CartReady([cartProduct.withQuantity(2), other]),
      ],
      verify: (bloc) {
        expect(repository.loads, 1);
        expect(bloc.state.quantityFor(1), 2);
        expect(bloc.state.quantityFor(2), 3);
        expect(bloc.state.totalQuantity, 5);
        expect(bloc.state.totalInCents, 47950);
      },
    );

    blocTest<CartNotifierBloc, CartState>(
      'Пустой результат даёт готовую корзину с нулевой суммой',
      build: () => CartNotifierBloc(repository),
      act: (bloc) => bloc.add(const CartStarted()),
      expect: () => [const CartLoading(), CartReady(const [])],
      verify: (bloc) {
        expect(repository.loads, 1);
        expect(bloc.state.totalQuantity, 0);
        expect(bloc.state.totalInCents, 0);
      },
    );

    for (final (title, error) in [
      ('Ошибка сети репозитория', const NetworkException.noConnection()),
      ('Ошибка чтения хранилища', const StorageException.read()),
    ]) {
      blocTest<CartNotifierBloc, CartState>(
        '$title переводит контроллер в состояние ошибки',
        setUp: () => repository.error = error,
        build: () => CartNotifierBloc(repository),
        act: (bloc) => bloc.add(const CartStarted()),
        expect: () => [const CartLoading(), CartLoadFailure(error)],
        verify: (bloc) {
          expect(repository.loads, 1);
          expect((bloc.state as CartLoadFailure).exception, same(error));
          expect(bloc.state.items, isEmpty);
        },
      );
    }

    blocTest<CartNotifierBloc, CartState>(
      'Повторный запуск не сбрасывает уже загруженную корзину',
      setUp: () => repository.items = [cartProduct],
      build: () => CartNotifierBloc(repository),
      act: (bloc) {
        bloc.add(const CartStarted());
        bloc.add(const CartStarted());
      },
      expect: () => [
        const CartLoading(),
        CartReady([cartProduct]),
      ],
      verify: (_) => expect(repository.loads, 1),
    );
  });

  test(
    'Startup and different mutation events share a single sequential queue',
    () async {
      final bloc = CartNotifierBloc(
        createCartRepository(MemoryCartPreferences()),
      );
      addTearDown(bloc.close);
      final finished = bloc.stream.firstWhere(
        (state) => state is CartReady && state.quantityFor(1) == 15,
      );
      bloc.add(const CartStarted());
      for (var i = 0; i < 10; i++) {
        bloc.add(const CartProductAdded(cartProduct));
        bloc.add(const CartQuantityIncreased(1));
        bloc.add(const CartQuantityDecreased(1));
      }
      bloc.add(CartProductAdded(cartProduct.withQuantity(5)));
      final state = await finished;
      expect(state.contains(1), isTrue);
      expect(state.totalQuantity, 15);
      expect(state.totalInCents, 337125);
      expect(await bloc.removeProduct(1), isTrue);
      expect(bloc.state.contains(1), isFalse);
      expect(bloc.state.totalQuantity, 0);
    },
  );

  test(
    'A failed removal reports failure and retains the entire saved group',
    () async {
      final preferences = MemoryCartPreferences();
      final repository = createCartRepository(preferences);
      await repository.add(cartProduct.withQuantity(4));
      final bloc = CartNotifierBloc(repository);
      addTearDown(bloc.close);
      await _start(bloc);

      preferences.failWrites = true;
      expect(await bloc.removeProduct(1), isFalse);
      expect(bloc.state, isA<CartUpdateFailure>());
      expect(bloc.state.quantityFor(1), 4);
      expect(await createCartRepository(preferences).load(), [
        cartProduct.withQuantity(4),
      ]);

      preferences.failWrites = false;
      expect(await bloc.removeProduct(1), isTrue);
      expect(bloc.state.items, isEmpty);
    },
  );

  test('A failed restore blocks mutations until retry succeeds', () async {
    final preferences = MemoryCartPreferences()..failReads = true;
    final bloc = CartNotifierBloc(createCartRepository(preferences));
    addTearDown(bloc.close);
    final failed = bloc.stream.firstWhere((state) => state is CartLoadFailure);
    bloc.add(const CartStarted());
    await failed;
    bloc.add(const CartProductAdded(cartProduct));
    expect(await bloc.removeProduct(1), isFalse);
    expect(preferences.writes, 0);

    preferences.failReads = false;
    await _start(bloc);
    final added = bloc.stream.firstWhere(
      (state) => state is CartReady && state.contains(1),
    );
    bloc.add(const CartProductAdded(cartProduct));
    await added;
    expect(preferences.writes, 1);
  });

  test('Closing settles outstanding swipe confirmations', () async {
    final preferences = MemoryCartPreferences();
    final repository = createCartRepository(preferences);
    await repository.add(cartProduct);
    final bloc = CartNotifierBloc(repository);
    await _start(bloc);
    final pending = Completer<void>();
    preferences.beforeWrite = () => pending.future;
    final saving = bloc.stream.firstWhere((state) => state is CartSaving);
    final removal = bloc.removeProduct(1);
    await saving;
    final closing = bloc.close();
    expect(await removal, isFalse);
    expect(await bloc.removeProduct(1), isFalse);
    pending.complete();
    await closing;
  });
}

Future<void> _start(CartNotifierBloc bloc) async {
  final ready = bloc.stream.firstWhere((state) => state is CartReady);
  bloc.add(const CartStarted());
  await ready;
}

class _LoadRepository extends Fake implements CartRepository {
  List<CartItem> items = const [];
  AppException? error;
  int loads = 0;

  @override
  Future<List<CartItem>> load() async {
    loads++;
    final failure = error;
    if (failure != null) throw failure;
    return items;
  }
}
