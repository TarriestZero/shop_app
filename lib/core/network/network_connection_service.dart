import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Следит за сетевыми интерфейсами. Доступность API проверяется HTTP-запросом.
class NetworkConnectionService {
  const NetworkConnectionService(this._connectivity);

  final Connectivity _connectivity;

  /// Возвращает текущее подключение и последующие изменения без повторов.
  /// Поздняя начальная проверка не заменяет более свежее событие платформы.
  Stream<bool> watch() => Stream<bool>.multi((controller) {
    var receivedEvent = false;
    var cancelled = false;
    final subscription = _connectivity.onConnectivityChanged.listen((results) {
      receivedEvent = true;
      controller.add(_hasConnection(results));
    }, onError: controller.addError);
    unawaited(
      _connectivity.checkConnectivity().then(
        (results) {
          if (!receivedEvent && !cancelled) {
            controller.add(_hasConnection(results));
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!receivedEvent && !cancelled) {
            controller.addError(error, stackTrace);
          }
        },
      ),
    );
    controller.onCancel = () {
      cancelled = true;
      return subscription.cancel();
    };
  }).distinct();

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
