import 'package:json_annotation/json_annotation.dart';

part 'product_dto.g.dart';

/// Товар из API. Ответ на частичное обновление содержит только изменённые поля.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ProductDto {
  const ProductDto({
    required this.id,
    this.title,
    this.price,
    this.description,
    this.category,
    this.image,
    this.rating,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  final int id;
  final String? title;
  final double? price;
  final String? description;
  final String? category;
  final String? image;
  final ProductRatingDto? rating;

  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);
}

@JsonSerializable()
class ProductRatingDto {
  const ProductRatingDto({required this.rate, required this.count});

  factory ProductRatingDto.fromJson(Map<String, dynamic> json) =>
      _$ProductRatingDtoFromJson(json);

  final double rate;
  final int count;

  Map<String, dynamic> toJson() => _$ProductRatingDtoToJson(this);
}

/// Поля для создания и изменения товара. Значения `null` пропускаются в запросе.
@JsonSerializable(includeIfNull: false)
class ProductRequestDto {
  const ProductRequestDto({
    this.title,
    this.price,
    this.description,
    this.category,
    this.image,
  });

  factory ProductRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ProductRequestDtoFromJson(json);

  final String? title;
  final double? price;
  final String? description;
  final String? category;
  final String? image;

  Map<String, dynamic> toJson() => _$ProductRequestDtoToJson(this);
}
