import 'package:json_annotation/json_annotation.dart';

part 'cart_dto.g.dart';

/// Корзина из API с поддержкой сокращённых ответов после обновления.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CartDto {
  const CartDto({required this.id, this.userId, this.date, this.products});

  factory CartDto.fromJson(Map<String, dynamic> json) =>
      _$CartDtoFromJson(json);

  final int id;
  final int? userId;
  final DateTime? date;
  final List<CartProductDto>? products;

  Map<String, dynamic> toJson() => _$CartDtoToJson(this);
}

@JsonSerializable()
class CartProductDto {
  const CartProductDto({required this.productId, required this.quantity});

  factory CartProductDto.fromJson(Map<String, dynamic> json) =>
      _$CartProductDtoFromJson(json);

  final int productId;
  final int quantity;

  Map<String, dynamic> toJson() => _$CartProductDtoToJson(this);
}

/// Поля для создания и изменения корзины. Значения `null` пропускаются в запросе.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CartRequestDto {
  const CartRequestDto({this.userId, this.date, this.products});

  factory CartRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CartRequestDtoFromJson(json);

  final int? userId;
  final DateTime? date;
  final List<CartProductDto>? products;

  Map<String, dynamic> toJson() => _$CartRequestDtoToJson(this);
}
