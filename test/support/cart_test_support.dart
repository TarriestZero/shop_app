import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/api/source/carts_api_source.dart';
import 'package:shop_app/core/storage/shared_preferences_service.dart';
import 'package:shop_app/features/cart/data/local/cart_local_data_source.dart';
import 'package:shop_app/features/cart/data/repositories/cart_repository.dart';
import 'package:shop_app/features/cart/domain/entity/cart_item.dart';

const cartProduct = CartItem(
  productId: 1,
  title: 'Постельное бельё Pavone',
  priceInCents: 22475,
  quantity: 1,
  category: 'Дом и текстиль',
);

CartRepository createCartRepository(MemoryCartPreferences preferences) =>
    CartRepository(_Client(), storage: CartLocalDataSource(preferences));

class MemoryCartPreferences extends Fake implements SharedPreferencesService {
  Map<String, Object?>? snapshot;
  bool failReads = false;
  bool failWrites = false;
  int writes = 0;
  Future<void> Function()? beforeWrite;

  @override
  Future<Map<String, Object?>?> getJson(String key) async {
    if (failReads) throw PlatformException(code: 'read_failed');
    return snapshot == null
        ? null
        : Map<String, Object?>.from(jsonDecode(jsonEncode(snapshot)) as Map);
  }

  @override
  Future<void> setJson(String key, Map<String, Object?> value) async {
    await beforeWrite?.call();
    if (failWrites) throw PlatformException(code: 'write_failed');
    writes++;
    snapshot = Map<String, Object?>.from(jsonDecode(jsonEncode(value)) as Map);
  }
}

class _Client extends Fake implements CartsApiSource {}
