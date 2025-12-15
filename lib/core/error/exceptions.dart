/// Excepción base para la aplicación
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Excepción de servidor
class ServerException extends AppException {
  ServerException(super.message, [super.statusCode]);
}

/// Excepción de caché
class CacheException extends AppException {
  CacheException(super.message);
}

/// Excepción de red/conexión
class NetworkException extends AppException {
  NetworkException(super.message);
}