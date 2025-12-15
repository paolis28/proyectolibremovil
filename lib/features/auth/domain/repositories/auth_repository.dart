import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository abstracto para Autenticación (Domain Layer)
/// Define el contrato que debe implementar la capa de datos
abstract class AuthRepository {
  /// Login con email y password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Registro de nuevo usuario
  Future<Either<Failure, User>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  });

  /// Obtener perfil del usuario actual
  Future<Either<Failure, User>> getProfile();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated();

  /// Obtener token actual
  Future<String?> getToken();
}