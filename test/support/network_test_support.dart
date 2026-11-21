import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/network/network_connection_service.dart';

class TestNetworkConnectionService extends Fake
    implements NetworkConnectionService {
  TestNetworkConnectionService([this.changes = const Stream.empty()]);

  final Stream<bool> changes;

  @override
  Stream<bool> watch() => changes;
}
