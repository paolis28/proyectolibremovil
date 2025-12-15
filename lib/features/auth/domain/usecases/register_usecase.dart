import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use Case para realizar registro
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    return await repository.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );
  }
}