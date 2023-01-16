part of sni_http;

class TimeoutException implements Exception {}

class HttpException implements Exception {
  final dynamic service;
  final dynamic error;
  HttpException([this.error, this.service]);

  @override
  String toString() {
    if (error != null) {
      return error.toString();
    }

    return super.toString();
  }
}

class CanceledException extends HttpException {}

class OtherException implements Exception {
  final Object? innerException;
  OtherException([this.innerException]);
}

class UnexpectedResultException implements Exception {
  UnexpectedResultException();
}

/// 400 Request Error
class RequestException extends HttpException {
  final String message;
  RequestException(this.message, [error, dynamic service])
      : super(error, service);

  @override
  String toString() {
    if (error != null) {
      return message;
    }

    return super.toString();
  }
}

/// 404 Exception
class NotFoundException extends HttpException {
  NotFoundException([error, dynamic service]) : super(error, service);
}

/// 500 Exception
class ServerException extends HttpException {
  ServerException([error, dynamic service]) : super(error, service);
}

/// 401 Exception
class UnauthorizedException extends HttpException {
  UnauthorizedException([error, dynamic service]) : super(error, service);
}
