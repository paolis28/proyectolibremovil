import 'package:equatable/equatable.dart';

/// Clase base abstracta para representar fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Fallo de servidor (500, etc.)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Fallo de conexión
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

/// Fallo de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}