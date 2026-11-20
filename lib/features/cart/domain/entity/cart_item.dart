import 'package:equatable/equatable.dart';

/// Сохранённые данные товара и количество его единиц. Цена — в центах USD.
class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.title,
    required this.priceInCents,
    required this.quantity,
    this.category = '',
    this.imageUrl,
  });

  final int productId;
  final String title;
  final int priceInCents;
  final int quantity;
  final String category;
  final String? imageUrl;

  int get totalInCents => priceInCents * quantity;

  /// Возвращает позицию с новым количеством и прежними данными товара.
  CartItem withQuantity(int quantity) => CartItem(
    productId: productId,
    title: title,
    priceInCents: priceInCents,
    quantity: quantity,
    category: category,
    imageUrl: imageUrl,
  );

  @override
  List<Object?> get props => [
    productId,
    title,
    priceInCents,
    quantity,
    category,
    imageUrl,
  ];
}
