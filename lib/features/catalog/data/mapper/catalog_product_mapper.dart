import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/features/catalog/domain/entity/catalog_product.dart';

/// Проверяет обязательные данные товара и переводит цену в центы.
CatalogProduct catalogProductFromDto(ProductDto dto) {
  final title = dto.title?.trim();
  final price = dto.price;
  if (title == null ||
      title.isEmpty ||
      price == null ||
      !price.isFinite ||
      price < 0) {
    throw const FormatException();
  }

  return CatalogProduct(
    id: dto.id,
    title: title,
    priceInCents: (price * 100).round(),
    category: dto.category ?? '',
    description: dto.description ?? '',
    imageUrl: dto.image,
  );
}
