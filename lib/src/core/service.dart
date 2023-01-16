part of sni_http;

abstract class Service {
  static String domain = 'sni.xetia.dev';

  String get baseUrl;

  void dispose();
}
