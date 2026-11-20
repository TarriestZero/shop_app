part of 'cart_notifier_bloc.dart';

sealed class CartState extends Equatable {
  const CartState();

  List<CartItem> get items => const [];

  /// Возвращает количество выбранного товара, либо ноль, если его нет в корзине.
  int quantityFor(int productId) {
    for (final item in items) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }

  bool contains(int productId) => quantityFor(productId) > 0;
  int get totalQuantity =>
      items.fold(0, (total, item) => total + item.quantity);
  int get totalInCents =>
      items.fold(0, (total, item) => total + item.totalInCents);

  @override
  List<Object?> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoadFailure extends CartState {
  const CartLoadFailure(this.exception);
  final AppException exception;

  @override
  List<Object?> get props => [exception];
}

sealed class CartData extends CartState {
  CartData(List<CartItem> items) : items = List.unmodifiable(items);

  @override
  final List<CartItem> items;

  @override
  List<Object?> get props => [items];
}

final class CartReady extends CartData {
  CartReady(super.items);
}

final class CartSaving extends CartData {
  CartSaving(super.items);
}

final class CartUpdateFailure extends CartData {
  CartUpdateFailure(super.items, this.exception);
  final AppException exception;

  @override
  List<Object?> get props => [...super.props, exception];
}
