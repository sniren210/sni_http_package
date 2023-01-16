part of sni_http;

mixin UpdateServiceMixin<T> on ApiService {
  Map<String, dynamic> toJson(T data);
  String get resource;

  /// update data by HTTP PUT method
  /// returning true if execution response code is 200
  Future<bool> update({required String id, required T data}) async {
    final res = await put(
      '$resource/$id',
      data: toJson(data),
    );

    if (res.statusCode == 200) {
      return true;
    }

    return false;
  }
}
