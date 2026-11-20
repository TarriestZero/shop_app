import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/cart_dto.dart';
import 'package:shop_app/api/source/carts_api_source.dart';
import 'package:shop_app/core/network/response_guard.dart';
import 'package:shop_app/features/cart/data/local/cart_local_data_source.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';

/// Хранит офлайн-корзину и предоставляет отдельные методы API корзин.
class CartRepository {
  CartRepository(this._client, {required this._storage});

  final CartsApiSource _client;
  final CartLocalDataSource _storage;
  List<CartItem>? _items;
  Future<void> _pending = Future.value();

  /// Восстанавливает локальную корзину перед первой операцией.
  Future<List<CartItem>> load() => _enqueue(_ensureLoaded);

  /// Добавляет единицы товара, объединяя позиции с одинаковым productId.
  Future<List<CartItem>> add(CartItem item) => _enqueue(() async {
    if (item.quantity <= 0 ||
        item.priceInCents < 0 ||
        item.title.trim().isEmpty) {
      throw ArgumentError.value(item);
    }
    final items = [...await _ensureLoaded()];
    final index = items.indexWhere(
      (current) => current.productId == item.productId,
    );
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = items[index].withQuantity(
        items[index].quantity + item.quantity,
      );
    }
    return _save(items);
  });

  /// Изменяет количество относительно последнего сохранённого снимка.
  /// При достижении нуля удаляет позицию целиком.
  Future<List<CartItem>> changeQuantity(int productId, int delta) =>
      _enqueue(() async {
        final items = [...await _ensureLoaded()];
        final index = items.indexWhere((item) => item.productId == productId);
        if (index == -1 || delta == 0) return _items!;
        final quantity = items[index].quantity + delta;
        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index] = items[index].withQuantity(quantity);
        }
        return _save(items);
      });

  /// Удаляет все единицы выбранного товара одной операцией.
  Future<List<CartItem>> remove(int productId) => _enqueue(() async {
    final items = await _ensureLoaded();
    if (!items.any((item) => item.productId == productId)) return items;
    return _save(items.where((item) => item.productId != productId).toList());
  });

  Future<List<CartItem>> _ensureLoaded() async =>
      _items ??= List.unmodifiable(await _storage.read());

  Future<List<CartItem>> _save(List<CartItem> items) async {
    await _storage.write(items);
    return _items = List.unmodifiable(items);
  }

  Future<List<CartItem>> _enqueue(Future<List<CartItem>> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  /// Получает корзины. Даты фильтра передаются в формате `YYYY-MM-DD`.
  Future<List<CartDto>> getCarts({
    int? limit,
    ApiSortOrder? sort,
    String? startDate,
    String? endDate,
  }) => guardNetwork(
    () => _client.getCarts(
      limit: limit,
      sort: sort,
      startDate: startDate,
      endDate: endDate,
    ),
  );

  /// Получает корзину по ID или возвращает `null`, если она отсутствует.
  Future<CartDto?> getCart(int id) => guardNetwork(() => _client.getCart(id));

  /// Получает корзины пользователя с фильтром дат в формате `YYYY-MM-DD`.
  Future<List<CartDto>> getUserCarts(
    int userId, {
    String? startDate,
    String? endDate,
  }) => guardNetwork(
    () => _client.getUserCarts(userId, startDate: startDate, endDate: endDate),
  );

  /// Отправляет данные новой корзины.
  Future<CartDto> createCart(CartRequestDto body) =>
      guardNetwork(() => _client.createCart(body));

  /// Отправляет полное обновление корзины.
  Future<CartDto> updateCart(int id, CartRequestDto body) =>
      guardNetwork(() => _client.updateCart(id, body));

  /// Отправляет изменённые поля корзины.
  Future<CartDto> patchCart(int id, CartRequestDto body) =>
      guardNetwork(() => _client.patchCart(id, body));

  /// Запрашивает удаление корзины и возвращает её данные, если она найдена.
  Future<CartDto?> deleteCart(int id) =>
      guardNetwork(() => _client.deleteCart(id));
}
