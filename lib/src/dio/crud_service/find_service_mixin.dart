part of sni_http;

mixin FindServiceMixin<T> on ApiService {
  T fromJson(Map<String, dynamic> map);
  String get resource;

  /// find data by page and limit
  Future<List<T>> find({Map<String, String>? query}) async {
    final res = await get(
      resource,
      queryParameters: query,
    );

    if (res.statusCode == 200) {
      return (res.data['results'] as List).map((e) => fromJson(e)).toList();
    }

    throw Exception('an error occured while read data');
  }

  /// get data by id resource/:id
  Future<T> findById(String id, {Map<String, String>? query}) async {
    final res = await get(
      '$resource/$id',
      queryParameters: query,
    );
    if (res.statusCode == 200) {
      return fromJson(res.data);
    }

    throw Exception('an error occured while read data');
  }
}
