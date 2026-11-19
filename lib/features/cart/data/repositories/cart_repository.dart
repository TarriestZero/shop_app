import 'package:shop_app/api/dto/api_sort_order.dart';
import 'package:shop_app/api/dto/cart_dto.dart';
import 'package:shop_app/api/source/carts_api_source.dart';
import 'package:shop_app/core/network/response_guard.dart';

/// Репозиторий корзин, работающий через клиент корзин.
class CartRepository {
  const CartRepository(this._client);

  final CartsApiSource _client;

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
