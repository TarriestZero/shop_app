import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/navigation/app_router.dart';

class ShopApp extends StatefulWidget {
  const ShopApp({super.key});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  final _router = AppRouter();

  late final RouterConfig<Object> _routerConfig;

  @override
  void initState() {
    super.initState();
    final config = _router.config();
    _routerConfig = RouterConfig<Object>(
      routeInformationProvider: config.routeInformationProvider,
      routeInformationParser: config.routeInformationParser,
      routerDelegate: config.routerDelegate,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shop App',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: createAppLightTheme(),
      routerConfig: _routerConfig,
    );
  }
}
