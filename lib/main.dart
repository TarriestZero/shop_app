import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/app/shop_app.dart';
import 'package:shop_app/core/storage/shared_preferences_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesService = SharedPreferencesService(SharedPreferencesAsync());

  runApp(
    RepositoryProvider.value(value: preferencesService, child: const ShopApp()),
  );
}
