import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/checkout/presentation/checkout/bloc/checkout_cubit.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

@RoutePage()
class CheckoutScreen extends StatefulWidget implements AutoRouteWrapper {
  const CheckoutScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (context) =>
        CheckoutCubit(clearCart: context.read<CartNotifierBloc>().clearCart),
    child: this,
  );

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fieldKeys = List.generate(
    4,
    (_) => GlobalKey<FormFieldState<String>>(),
  );
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _formValid = false;

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _address]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateFormValidity() {
    // Пассивная проверка не меняет errorText у нетронутых полей.
    final valid = _fieldKeys.every((key) => key.currentState?.isValid ?? false);
    if (valid != _formValid) setState(() => _formValid = valid);
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid != _formValid) setState(() => _formValid = valid);
    if (!valid) return;
    final cart = context.read<CartNotifierBloc>().state;
    if (cart is! CartData || cart is CartSaving || cart.items.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<CheckoutCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen: (previous, current) => current is CheckoutSuccess,
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          context.router.replace(
            OrderConfirmationRoute(orderId: state.orderId),
          );
        }
      },
      builder: (context, checkout) {
        final busy =
            checkout is CheckoutSubmitting || checkout is CheckoutSuccess;
        return PopScope(
          canPop: !busy,
          child: Scaffold(
            appBar: AppBar(title: Text(strings.checkoutTitle)),
            body: SafeArea(
              top: false,
              child: BlocBuilder<CartNotifierBloc, CartState>(
                builder: (context, cart) {
                  if (cart is CartLoadFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userErrorMessage(
                                cart.exception,
                                strings,
                                fallback: strings.cartLoadFailed,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: strings.retry,
                              onPressed: () => context
                                  .read<CartNotifierBloc>()
                                  .add(const CartStarted()),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (cart is! CartData) {
                    return Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: strings.cartLoading,
                      ),
                    );
                  }
                  if (cart.items.isEmpty && !busy) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(strings.emptyCart),
                            const SizedBox(height: 16),
                            AppButton(
                              label: strings.returnToCatalog,
                              onPressed: () => context.router.replaceAll([
                                const MainRoute(children: [CatalogRoute()]),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final total = NumberFormat.simpleCurrency(
                    locale: strings.localeName,
                    name: 'USD',
                  ).format(cart.totalInCents / 100);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        onChanged: _updateFormValidity,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: strings.checkoutName,
                              formFieldKey: _fieldKeys[0],
                              autovalidateMode:
                                  AutovalidateMode.onUserInteractionIfError,
                              type: AppTextFieldType.name,
                              controller: _name,
                              isRequired: true,
                              enabled: !busy,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: strings.checkoutEmail,
                              formFieldKey: _fieldKeys[1],
                              autovalidateMode:
                                  AutovalidateMode.onUserInteractionIfError,
                              type: AppTextFieldType.email,
                              controller: _email,
                              isRequired: true,
                              enabled: !busy,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: strings.checkoutPhone,
                              formFieldKey: _fieldKeys[2],
                              autovalidateMode:
                                  AutovalidateMode.onUserInteractionIfError,
                              type: AppTextFieldType.phone,
                              controller: _phone,
                              isRequired: true,
                              enabled: !busy,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: strings.checkoutAddress,
                              formFieldKey: _fieldKeys[3],
                              autovalidateMode:
                                  AutovalidateMode.onUserInteractionIfError,
                              type: AppTextFieldType.address,
                              controller: _address,
                              isRequired: true,
                              enabled: !busy,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Text(
                                  strings.cartTotal,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  total,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            if (checkout is CheckoutFailure) ...[
                              const SizedBox(height: 16),
                              Text(
                                strings.checkoutFailed,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 24),
                            AppButton(
                              label: busy
                                  ? strings.checkoutSubmitting
                                  : strings.checkoutSubmit,
                              isLoading: busy,
                              onPressed:
                                  _formValid && !busy && cart is! CartSaving
                                  ? _submit
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
