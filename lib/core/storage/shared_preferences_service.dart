import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Читает и сохраняет данные через [SharedPreferencesAsync].
class SharedPreferencesService {
  /// Создаёт сервис на основе переданного хранилища настроек.
  const SharedPreferencesService(this._preferences);

  final SharedPreferencesAsync _preferences;

  /// Возвращает логическое значение по [key] или `null`, если ключ отсутствует.
  Future<bool?> getBool(String key) => _preferences.getBool(key);

  /// Сохраняет логическое значение [value] по ключу [key].
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  /// Возвращает целое число по [key] или `null`, если ключ отсутствует.
  Future<int?> getInt(String key) => _preferences.getInt(key);

  /// Сохраняет целое число [value] по ключу [key].
  Future<void> setInt(String key, int value) => _preferences.setInt(key, value);

  /// Возвращает дробное число по [key] или `null`, если ключ отсутствует.
  Future<double?> getDouble(String key) => _preferences.getDouble(key);

  /// Сохраняет дробное число [value] по ключу [key].
  Future<void> setDouble(String key, double value) =>
      _preferences.setDouble(key, value);

  /// Возвращает строку по [key] или `null`, если ключ отсутствует.
  Future<String?> getString(String key) => _preferences.getString(key);

  /// Сохраняет строку [value] по ключу [key].
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  /// Возвращает список строк по [key] или `null`, если ключ отсутствует.
  Future<List<String>?> getStringList(String key) =>
      _preferences.getStringList(key);

  /// Сохраняет список строк [value] по ключу [key].
  Future<void> setStringList(String key, List<String> value) =>
      _preferences.setStringList(key, value);

  /// Возвращает JSON-объект по [key] или `null`, если ключ отсутствует.
  ///
  /// Выбрасывает [FormatException] при некорректном JSON или другом типе
  /// JSON-значения.
  Future<Map<String, Object?>?> getJson(String key) async {
    final encoded = await _preferences.getString(key);
    if (encoded == null) return null;

    final Object? decoded = jsonDecode(encoded);
    if (decoded is! Map<String, Object?>) {
      throw FormatException('Expected a JSON object for key "$key".');
    }

    return decoded;
  }

  /// Сериализует [value] в JSON и сохраняет строку по ключу [key].
  Future<void> setJson(String key, Map<String, Object?> value) =>
      _preferences.setString(key, jsonEncode(value));

  /// Проверяет наличие ключа [key] в хранилище.
  Future<bool> containsKey(String key) => _preferences.containsKey(key);

  /// Удаляет ключ [key] и его значение, если они существуют.
  Future<void> remove(String key) => _preferences.remove(key);

  /// Удаляет ключи из [allowList], а при `null` очищает всё хранилище.
  Future<void> clear({Set<String>? allowList}) =>
      _preferences.clear(allowList: allowList);
}
