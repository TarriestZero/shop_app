import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/exceptions/app_exception.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';

/// Разрешает оформление после проверки подключения и учитывает ошибки связи с API.
class CheckoutConnectionCubit extends Cubit<bool> {
  CheckoutConnectionCubit(
    this._repository, {
    required Stream<bool> connectionChanges,
  }) : super(false) {
    _offlineSubscription = _repository.offlineChanges.listen((_) => _update());
    _connectionSubscription = connectionChanges.distinct().listen(
      (connected) {
        _connected = connected;
        _update();
        if (connected && _repository.isOffline) unawaited(_refresh());
      },
      onError: (Object _) {
        _connected = false;
        _update();
      },
    );
  }

  final CatalogRepository _repository;
  late final StreamSubscription<bool> _connectionSubscription;
  late final StreamSubscription<bool> _offlineSubscription;
  bool _connected = false;

  void _update() {
    if (!isClosed) emit(_connected && !_repository.isOffline);
  }

  Future<void> _refresh() async {
    try {
      await _repository.loadCatalog();
    } on AppException {
      // Состояние сети уже сохранено репозиторием; корзина остаётся доступной.
    }
    _update();
  }

  @override
  Future<void> close() async {
    final closing = super.close();
    await _connectionSubscription.cancel();
    await _offlineSubscription.cancel();
    await closing;
  }
}
