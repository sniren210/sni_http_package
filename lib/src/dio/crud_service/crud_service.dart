part of sni_http;

/// abstract class for base of CRUD HTTP Service
/// has methods [find], [findById], [add], [update], [remove]
abstract class CrudService<T> extends ApiService
    with
        FindServiceMixin<T>,
        InsertServiceMixin<T>,
        UpdateServiceMixin<T>,
        DeleteServiceMixin<T> {
  CrudService(HttpService httpClient) : super(httpClient);

  @override
  T fromJson(Map<String, dynamic> map);

  @override
  Map<String, dynamic> toJson(T data);

  @override
  String get resource;
}
