part of sni_http;

mixin InsertServiceMixin<T> on ApiService {
  Map<String, dynamic> toJson(T data);
  String get resource;

  /// create data by HTTP POST to resource
  /// returning true if execution response code is 200
  Future<bool> add(T data) async {
    final res = await post(
      resource,
      data: toJson(data),
    );

    if (res.statusCode == 200) {
      return true;
    }

    return false;
  }
}
