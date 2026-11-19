/// Общие настройки подключения к Fake Store API.
abstract final class ApiConfig {
  static const baseUrl = 'https://fakestoreapi.com';
  static const timeout = Duration(seconds: 30);
}
