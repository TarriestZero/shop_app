import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/cart/data/repositories/cart_repository.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';

part 'cart_notifier_event.dart';
part 'cart_notifier_state.dart';

/// Глобальное состояние корзины. Все события обрабатываются последовательно.
class CartNotifierBloc extends Bloc<CartEvent, CartState> {
  CartNotifierBloc(this._repository) : super(const CartInitial()) {
    on<CartEvent>(
      _onEvent,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  final CartRepository _repository;
  final _commands = <Completer<bool>>{};
  bool _closing = false;

  /// Удаляет всю позицию и возвращает результат сохранения для Dismissible.
  /// Ожидается результат команды, без подписок на состояния других блоков.
  Future<bool> removeProduct(int productId) =>
      _runCommand((completion) => CartProductRemoved(productId, completion));

  /// Очищает непустую корзину для оформления. При ошибке или отсутствии товаров
  /// возвращает false и сохраняет прежнее состояние.
  Future<bool> clearCart() => _runCommand(CartCleared.new);

  Future<bool> _runCommand(CartEvent Function(Completer<bool>) createEvent) {
    if (_closing || isClosed) return Future.value(false);
    final completion = Completer<bool>();
    _commands.add(completion);
    add(createEvent(completion));
    return completion.future.whenComplete(() => _commands.remove(completion));
  }

  Future<void> _onEvent(CartEvent event, Emitter<CartState> emit) async {
    if (event is CartStarted) {
      if (state is CartData) return;
      emit(const CartLoading());
      try {
        emit(CartReady(await _repository.load()));
      } on AppException catch (error) {
        emit(CartLoadFailure(error));
      }
      return;
    }

    final current = state;
    if (current is! CartData) {
      _completeCommand(event, false);
      return;
    }
    if (event is CartCleared && current.items.isEmpty) {
      _completeCommand(event, false);
      return;
    }
    emit(CartSaving(current.items));
    try {
      final items = await switch (event) {
        CartProductAdded() => _repository.add(event.item),
        CartQuantityIncreased() => _repository.changeQuantity(
          event.productId,
          1,
        ),
        CartQuantityDecreased() => _repository.changeQuantity(
          event.productId,
          -1,
        ),
        CartProductRemoved() => _repository.remove(event.productId),
        CartCleared() => _repository.clear(),
        CartStarted() => throw StateError('Unexpected cart initialization'),
      };
      emit(CartReady(items));
      _completeCommand(event, true);
    } on AppException catch (error) {
      emit(CartUpdateFailure(current.items, error));
      _completeCommand(event, false);
    }
  }

  void _completeCommand(CartEvent event, bool success) {
    final completion = switch (event) {
      CartProductRemoved() => event.completion,
      CartCleared() => event.completion,
      _ => null,
    };
    if (completion != null && !completion.isCompleted) {
      completion.complete(success);
    }
  }

  @override
  Future<void> close() {
    _closing = true;
    for (final completion in _commands) {
      if (!completion.isCompleted) completion.complete(false);
    }
    return super.close();
  }
}
