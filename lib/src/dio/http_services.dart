// ignore_for_file: unused_element

part of sni_http;

// Must be top-level function
dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

Future<dynamic> _parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class HttpService with DioMixin {
  HttpService([BaseOptions? options]) {
    this.options = options ?? BaseOptions();
    httpClientAdapter = createAdapter();
  }

  final _completers = <_HttpRequest, dynamic>{};
  @override
  void close({bool force = false}) {
    for (final completer in _completers.values) {
      if (completer is Completer) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('canceled'));
        }
      }
    }

    _completers.clear();
    super.close(force: force);
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (options?.extra?['force'] ?? false) {
      return await retry(
        () => super.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
        ),
        retryIf: (e) =>
            e is DioError &&
            [
              DioErrorType.connectTimeout,
              DioErrorType.receiveTimeout,
              DioErrorType.sendTimeout
            ].contains(e.type),
      );
    }

    final request = _HttpRequest(
      path: path,
      queryParameters: queryParameters,
      headers: options?.headers,
    );

    if (_completers.containsKey(request)) {
      return _completers[request]!.future;
    }

    final completer = Completer<Response<T>>();
    retry(
      () => super.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      ),
      retryIf: (e) =>
          e is DioError &&
          [
            DioErrorType.connectTimeout,
            DioErrorType.receiveTimeout,
            DioErrorType.sendTimeout
          ].contains(e.type),
    ).then(
      (value) {
        if (!completer.isCompleted) completer.complete(value);
        Future.delayed(
          const Duration(seconds: 5),
          () {
            _completers.remove(request);
          },
        );
      },
    ).onError(
      (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error!, stackTrace);
        }
      },
    );

    _completers[request] = completer;
    return completer.future;
  }

  @override
  Future<Response<T>> request<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final fixedData = data != null ? _fixTimezone(data) : data;
      final res = await super.request<T>(
        path,
        data: fixedData,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return res;
    } on DioError catch (e, s) {
      if (throwDioError != null) {
        await throwDioError?.call(e, s);
      } else {
        rethrow;
      }
    } on ModelParseException {
      rethrow;
    } catch (e) {
      throw OtherException(e);
    }

    throw UnexpectedResultException();
  }

  FutureOr<void> Function(DioError e, StackTrace? stackTrace)? throwDioError;

  void dispose() {
    close(force: true);
  }

  dynamic _fixTimezone(dynamic data) {
    if (data is Map) {
      return _fixMap(data);
    }

    if (data is List) {
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        if (item is Map) {
          data[i] = _fixMap(item);
        }
      }

      return data;
    }

    return data;
  }

  Map _fixMap(Map data) {
    for (final key in data.keys) {
      final item = data[key];
      if (item is DateTime) {
        data[key] = item.toUtc();
        continue;
      }

      if (item is Map) {
        final fixed = _fixMap(item);
        data[key] = fixed;
      }
    }

    return data;
  }
}

class _HttpRequest {
  final String path;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;

  _HttpRequest({
    required this.path,
    this.queryParameters,
    this.headers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HttpRequest &&
          other.path == path &&
          other.queryParameters == queryParameters &&
          other.headers == headers;

  @override
  int get hashCode => Object.hashAll([
        path,
        queryParameters,
        headers,
      ]);
}
