import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/api/dto/product_dto.dart';
import 'package:shop_app/core/exceptions/network_exception.dart';
import 'package:shop_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shop_app/features/checkout/presentation/checkout/bloc/checkout_connection_cubit.dart';

import '../../support/catalog_test_support.dart';

void main() {
  late StreamController<bool> connections;
  late CatalogTestClient client;
  late CatalogRepository repository;
  late CheckoutConnectionCubit cubit;

  setUp(() {
    connections = StreamController<bool>.broadcast();
    client = CatalogTestClient();
    repository = CatalogRepository(
      client,
      connectionChanges: connections.stream,
    );
    cubit = CheckoutConnectionCubit(
      repository,
      connectionChanges: connections.stream,
    );
  });

  tearDown(() async {
    await cubit.close();
    await repository.close();
    await connections.close();
  });

  test('До проверки подключения оформление недоступно', () async {
    expect(cubit.state, isFalse);
    connections.add(true);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isTrue);
    expect(client.requests, 0);
  });

  test(
    'Потеря сети блокирует оформление, восстановление разрешает его',
    () async {
      connections.add(true);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isTrue);
      connections.add(false);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isFalse);
      connections.add(true);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isTrue);
      expect(client.requests, 1);
    },
  );

  test(
    'Wi-Fi без доступа к API блокирует оформление даже без снимка каталога',
    () async {
      connections.add(true);
      await Future<void>.delayed(Duration.zero);
      client.error = const NetworkException.noConnection();
      await expectLater(
        repository.loadCatalog(),
        throwsA(isA<NetworkException>()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(repository.snapshot, isNull);
      expect(cubit.state, isFalse);

      client.error = null;
      await repository.loadCatalog();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isTrue);
    },
  );

  test('Неудачный запрос после восстановления интерфейса оставляет оформление недоступным', () async {
    connections.add(false);
    await Future<void>.delayed(Duration.zero);
    client.error = const NetworkException.noConnection();
    connections.add(true);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isFalse);
    expect(client.requests, 1);
  });

  test('Закрытие во время проверки сети не публикует состояние', () async {
    connections.add(false);
    await Future<void>.delayed(Duration.zero);
    final pending = Completer<List<ProductDto>>();
    client.fetch = () => pending.future;
    connections.add(true);
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    pending.complete(const [detailsProduct]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isFalse);
  });
}
