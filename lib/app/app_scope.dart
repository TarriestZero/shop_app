import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/api/api_config.dart';
import 'package:shop_app/core/network/empty_response_interceptor.dart';
import 'package:shop_app/core/storage/shared_preferences_service.dart';

/// Предоставляет общий HTTP-клиент и сервис хранения всему приложению.
class AppScope extends StatelessWidget {
  const AppScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Dio>(
          create: (_) => Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.timeout,
              sendTimeout: ApiConfig.timeout,
              receiveTimeout: ApiConfig.timeout,
              contentType: Headers.jsonContentType,
            ),
          )..interceptors.add(EmptyResponseInterceptor()),
          dispose: (dio) => dio.close(),
        ),
        RepositoryProvider(
          create: (_) => SharedPreferencesService(SharedPreferencesAsync()),
        ),
      ],
      child: child,
    );
  }
}
