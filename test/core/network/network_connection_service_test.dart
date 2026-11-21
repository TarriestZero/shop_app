import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/network/network_connection_service.dart';

void main() {
  test(
    'Начальное подключение и смена интерфейсов не дублируют статус',
    () async {
      final connectivity = _Connectivity();
      final states = <bool>[];
      final subscription = NetworkConnectionService(connectivity)
          .watch()
          .listen(states.add);
      connectivity.initial.complete([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      connectivity.events.add([ConnectivityResult.mobile]);
      connectivity.events.add([ConnectivityResult.none]);
      connectivity.events.add([
        ConnectivityResult.wifi,
        ConnectivityResult.mobile,
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(states, [true, false, true]);
      await subscription.cancel();
      expect(connectivity.events.hasListener, isFalse);
      await connectivity.events.close();
    },
  );

  test('Поздняя начальная проверка не отменяет событие потери сети', () async {
    final connectivity = _Connectivity();
    final states = <bool>[];
    final subscription = NetworkConnectionService(connectivity)
        .watch()
        .listen(states.add);
    connectivity.events.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    connectivity.initial.complete([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);
    expect(states, [false]);
    await subscription.cancel();
    await connectivity.events.close();
  });

  test('Завершение проверки после отмены подписки безопасно', () async {
    final connectivity = _Connectivity();
    final states = <bool>[];
    final subscription = NetworkConnectionService(connectivity)
        .watch()
        .listen(states.add);
    await subscription.cancel();
    connectivity.initial.complete([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);
    expect(states, isEmpty);
    expect(connectivity.events.hasListener, isFalse);
    await connectivity.events.close();
  });
}

class _Connectivity extends Fake implements Connectivity {
  final initial = Completer<List<ConnectivityResult>>();
  final events = StreamController<List<ConnectivityResult>>();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() => initial.future;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => events.stream;
}
