import 'package:equatable/equatable.dart';

/// Данные товара для каталога. Цена хранится в центах USD.
class CatalogProduct extends Equatable {
  const CatalogProduct({
    required this.id,
    required this.title,
    required this.priceInCents,
    required this.category,
    required this.description,
    this.imageUrl,
    this.rating,
    this.ratingCount,
  });

  final int id;
  final String title;
  final int priceInCents;
  final String category;
  final String description;
  final String? imageUrl;
  final double? rating;
  final int? ratingCount;

  @override
  List<Object?> get props => [
    id,
    title,
    priceInCents,
    category,
    description,
    imageUrl,
    rating,
    ratingCount,
  ];
}
