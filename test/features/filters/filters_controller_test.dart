import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/exceptions/index.dart';
import 'package:shop_app/features/filters/domain/repository/filters_repository.dart';
import 'package:shop_app/features/filters/presentation/filters/bloc/filters_controller.dart';

void main() {
  late _Repository repository;
  late FiltersController<String> controller;

  setUp(() {
    repository = _Repository();
    controller = FiltersController(
      repository: repository,
      initialFilters: 'initial',
      defaultFilters: 'all',
    );
  });

  tearDown(() => controller.close());

  test('Only the latest selection may update the count or error', () async {
    final old = Completer<int>();
    repository.fetch = (filters) =>
        filters == 'old' ? old.future : Future.value(3);
    final outdated = controller.update('old');
    await controller.update('new');
    old.completeError(const NetworkException.noConnection());
    await outdated;

    expect(controller.state, const FiltersReady('new', 3));
  });

  test(
    'Apply waits for the count, allows zero results and runs once',
    () async {
      final pending = Completer<int>();
      repository.fetch = (_) => pending.future;
      final loading = controller.load();
      controller.apply();
      expect(controller.state, const FiltersLoading('initial'));
      expect(controller.state.count, isNull);

      pending.complete(0);
      await loading;
      controller.apply();
      expect(controller.state, const FiltersApplied('initial', 0));
      final applied = controller.state;
      controller.apply();
      expect(controller.state, same(applied));
    },
  );

  test('A failure preserves the draft and supports retry and reset', () async {
    repository.fetch = (_) =>
        Future.error(const NetworkException.server(statusCode: 503));
    await controller.update('chosen');
    expect(
      controller.state,
      const FiltersFailure('chosen', NetworkException.server(statusCode: 503)),
    );
    controller.apply();
    expect(controller.state, isA<FiltersFailure<String>>());

    repository.fetch = (filters) async => filters == 'all' ? 10 : 2;
    await controller.load();
    expect(controller.state, const FiltersReady('chosen', 2));
    await controller.reset();
    expect(controller.state, const FiltersReady('all', 10));
  });

  test('A count completing after close does not emit', () async {
    final pending = Completer<int>();
    repository.fetch = (_) => pending.future;
    final loading = controller.load();
    await controller.close();
    pending.complete(5);
    await expectLater(loading, completes);
  });
}

class _Repository extends FiltersRepository<String> {
  Future<int> Function(String) fetch = (_) async => 0;

  @override
  Future<int> count(String filters) => fetch(filters);
}
