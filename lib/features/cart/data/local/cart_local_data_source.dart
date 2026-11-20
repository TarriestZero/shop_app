import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/core/storage/shared_preferences_service.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';

/// Хранит весь снимок корзины одной JSON-строкой в shared_preferences.
class CartLocalDataSource {
  const CartLocalDataSource(this._storage);

  final SharedPreferencesService _storage;
  static const _key = 'cart_items';
  static const _version = 1;

  /// Восстанавливает корзину. Повреждённые данные не заменяются пустой корзиной.
  Future<List<CartItem>> read() async {
    try {
      final json = await _storage.getJson(_key);
      if (json == null) return const [];
      if (json['version'] != _version || json['items'] is! List) {
        throw const FormatException();
      }
      final ids = <int>{};
      return (json['items'] as List)
          .map((value) {
            if (value is! Map) throw const FormatException();
            final id = value['productId'];
            final title = value['title'];
            final price = value['priceInCents'];
            final quantity = value['quantity'];
            final category = value['category'];
            final image = value['imageUrl'];
            if (id is! int ||
                !ids.add(id) ||
                title is! String ||
                title.trim().isEmpty ||
                price is! int ||
                price < 0 ||
                quantity is! int ||
                quantity <= 0 ||
                category is! String ||
                (image != null && image is! String)) {
              throw const FormatException();
            }
            return CartItem(
              productId: id,
              title: title,
              priceInCents: price,
              quantity: quantity,
              category: category,
              imageUrl: image as String?,
            );
          })
          .toList(growable: false);
    } on AppException {
      rethrow;
    } on Exception catch (_, stackTrace) {
      Error.throwWithStackTrace(const StorageException.read(), stackTrace);
    }
  }

  /// Сохраняет снимок до публикации нового состояния корзины.
  Future<void> write(List<CartItem> items) async {
    try {
      await _storage.setJson(_key, {
        'version': _version,
        'items': [
          for (final item in items)
            {
              'productId': item.productId,
              'title': item.title,
              'priceInCents': item.priceInCents,
              'quantity': item.quantity,
              'category': item.category,
              'imageUrl': item.imageUrl,
            },
        ],
      });
    } on AppException {
      rethrow;
    } on Exception catch (_, stackTrace) {
      Error.throwWithStackTrace(const StorageException.write(), stackTrace);
    }
  }
}
