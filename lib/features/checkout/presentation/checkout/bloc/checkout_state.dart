part of 'checkout_cubit.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

final class CheckoutFailure extends CheckoutState {
  const CheckoutFailure();
}

final class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
