part of sni_http;

abstract class ApiService extends Service {
  late final HttpService _httpClient;

  @override
  String get baseUrl => 'https://${Service.domain}/';

  String get groupUrl => '';

  ApiService([HttpService? httpClient]) {
    _httpClient = httpClient ?? HttpService();

    String baseURL = '';
    if (_httpClient.options.baseUrl.isNotEmpty) {
      baseURL = _httpClient.options.baseUrl;
    }

    if (baseURL.isEmpty) {
      baseURL = baseUrl;
    }

    if (baseURL.isNotEmpty && !baseURL.endsWith('/')) {
      baseURL = '$baseURL/';
    }

    String groupURL = groupUrl;
    if (groupUrl.isNotEmpty && !groupUrl.endsWith('/')) {
      groupURL = '$groupURL/';
    }

    _httpClient.options = _httpClient.options.copyWith(baseUrl: baseURL);

    _httpClient.throwDioError = _throwDioError;
  }

  set options(BaseOptions value) {
    _httpClient.options = value;
  }

  Interceptors get interceptors => _httpClient.interceptors;

  @override
  void dispose() {
    _httpClient.dispose();
  }

  Future<void> _throwDioError(DioError e, StackTrace? stackTrace) async {
    if (e.type == DioErrorType.response) {
      final res = e.response;

      String message = '';
      if (res?.data is String) {
        message = res?.data;
      }

      if (res?.data is Map) {
        if (res!.data.containsKey('detail')) {
          message = res.data['detail'].toString();
        }
      }

      if (message.isNotEmpty) {
        throw RequestException(
          message,
          e,
          this,
        );
      }

      switch (res?.statusCode) {
        case 400:
          throw RequestException(
            message,
            e,
            this,
          );
        case 401:
        case 403:
          throw UnauthorizedException(
            e,
            this,
          );

        case 404:
          throw NotFoundException(
            e,
            this,
          );
      }

      if ((res?.statusCode ?? 0) >= 500) {
        throw ServerException(e, this);
      }
    }

    if (e.type == DioErrorType.cancel) {
      throw CanceledException();
    }

    throw HttpException(e, this);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      _httpClient.get<T>(
        '$groupUrl$path',
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _httpClient.post<T>(
        '$groupUrl$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _httpClient.put<T>(
        '$groupUrl$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _httpClient.delete<T>(
        '$groupUrl$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response<T>> request<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _httpClient.request<T>(
        '$groupUrl$path',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
}
