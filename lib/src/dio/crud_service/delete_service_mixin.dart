part of sni_http;

mixin DeleteServiceMixin<T> on ApiService {
  String get resource;
  Map<String, dynamic> toJson(T data);

  /// update data by HTTP PUT method
  /// returning true if execution response code is 200
  Future<bool> remove({required String id, T? data}) async {
    final res = await delete(
      '$resource/$id',
      data: data == null ? null : toJson(data),
    );

    if (res.statusCode == 200) {
      return true;
    }

    return false;
  }
}
