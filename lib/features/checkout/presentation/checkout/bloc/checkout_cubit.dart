import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'checkout_state.dart';

abstract interface class CheckoutActions {
  Future<void> submit();
}

/// Оформляет локальный заказ через команду сохранения пустой корзины.
/// Валидация полей остаётся в Form и TextFormField представления.
class CheckoutCubit extends Cubit<CheckoutState> implements CheckoutActions {
  CheckoutCubit({required this._clearCart, String Function()? createOrderId})
    : _createOrderId = createOrderId ?? _localOrderId,
      super(const CheckoutInitial());

  final Future<bool> Function() _clearCart;
  final String Function() _createOrderId;

  static String _localOrderId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  /// Создаёт номер заказа после успешной очистки корзины; повторное нажатие
  /// во время оформления или после успеха игнорируется.
  @override
  Future<void> submit() async {
    if (isClosed || state is CheckoutSubmitting || state is CheckoutSuccess) {
      return;
    }
    emit(const CheckoutSubmitting());
    final cleared = await _clearCart();
    if (isClosed) return;
    emit(cleared ? CheckoutSuccess(_createOrderId()) : const CheckoutFailure());
  }
}
