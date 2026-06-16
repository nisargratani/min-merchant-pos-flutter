/// Thrown when an API call returns an error response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when there is no internet connection.
class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when local database operations fail.
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache operation failed'});

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when the user is not authenticated.
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({this.message = 'Unauthorized'});

  @override
  String toString() => 'UnauthorizedException: $message';
}
