// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  description: json['description'] as String?,
  category: json['category'] as String?,
  image: json['image'] as String?,
  rating: json['rating'] == null
      ? null
      : ProductRatingDto.fromJson(json['rating'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductDtoToJson(ProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': ?instance.title,
      'price': ?instance.price,
      'description': ?instance.description,
      'category': ?instance.category,
      'image': ?instance.image,
      'rating': ?instance.rating?.toJson(),
    };

ProductRatingDto _$ProductRatingDtoFromJson(Map<String, dynamic> json) =>
    ProductRatingDto(
      rate: (json['rate'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ProductRatingDtoToJson(ProductRatingDto instance) =>
    <String, dynamic>{'rate': instance.rate, 'count': instance.count};

ProductRequestDto _$ProductRequestDtoFromJson(Map<String, dynamic> json) =>
    ProductRequestDto(
      title: json['title'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$ProductRequestDtoToJson(ProductRequestDto instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'price': ?instance.price,
      'description': ?instance.description,
      'category': ?instance.category,
      'image': ?instance.image,
    };
