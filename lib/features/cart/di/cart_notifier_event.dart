part of 'cart_notifier_bloc.dart';

sealed class CartEvent {
  const CartEvent();
}

final class CartStarted extends CartEvent {
  const CartStarted();
}

final class CartProductAdded extends CartEvent {
  const CartProductAdded(this.item);

  final CartItem item;
}

final class CartQuantityIncreased extends CartEvent {
  const CartQuantityIncreased(this.productId);

  final int productId;
}

final class CartQuantityDecreased extends CartEvent {
  const CartQuantityDecreased(this.productId);

  final int productId;
}

final class CartProductRemoved extends CartEvent {
  const CartProductRemoved(this.productId, this.completion);

  final int productId;
  final Completer<bool> completion;
}

final class CartCleared extends CartEvent {
  const CartCleared(this.completion);

  final Completer<bool> completion;
}
