import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/features/cart/di/cart_notifier_bloc.dart';
import 'package:shop_app/features/cart/presentation/widgets/cart_tab_icon.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return BlocListener<CartNotifierBloc, CartState>(
      listenWhen: (previous, current) => current is CartUpdateFailure,
      listener: (context, state) {
        if (state is! CartUpdateFailure) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userErrorMessage(
                state.exception,
                strings,
                fallback: strings.cartUpdateFailed,
              ),
            ),
          ),
        );
      },
      child: AutoTabsRouter(
        routes: const [CatalogRoute(), CartRoute()],
        homeIndex: 0,
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);

          return Scaffold(
            body: child,
            bottomNavigationBar: AppNavigationBar(
              selectedIndex: tabsRouter.activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon: const Icon(Icons.grid_view_rounded),
                  label: strings.catalogTitle,
                ),
                NavigationDestination(
                  icon: const CartTabIcon(),
                  selectedIcon: const CartTabIcon(selected: true),
                  label: strings.cartTitle,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
