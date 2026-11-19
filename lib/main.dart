import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/api/source/auth_api_source.dart';
import 'package:shop_app/api/source/carts_api_source.dart';
import 'package:shop_app/api/source/products_api_source.dart';
import 'package:shop_app/api/source/users_api_source.dart';
import 'package:shop_app/app/app_scope.dart';
import 'package:shop_app/app/shop_app.dart';
import 'package:shop_app/core/storage/shared_preferences_service.dart';
import 'package:shop_app/features/auth/data/repositories/auth_repository.dart';
import 'package:shop_app/features/cart/data/repositories/cart_repository.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/catalog/data/local/catalog_local_data_source.dart';
import 'package:shop_app/features/users/data/repositories/users_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    AppScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => CatalogRepository(
              ProductsApiSource(context.read<Dio>()),
              cache: CatalogLocalDataSource(
                context.read<SharedPreferencesService>(),
              ),
            ),
          ),
          RepositoryProvider(
            create: (context) =>
                CartRepository(CartsApiSource(context.read<Dio>())),
          ),
          RepositoryProvider(
            create: (context) =>
                UsersRepository(UsersApiSource(context.read<Dio>())),
          ),
          RepositoryProvider(
            create: (context) =>
                AuthRepository(AuthApiSource(context.read<Dio>())),
          ),
        ],
        child: const ShopApp(),
      ),
    ),
  );
}
