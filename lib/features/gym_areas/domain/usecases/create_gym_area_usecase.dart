import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/gym_area.dart';
import '../repositories/gym_areas_repository.dart';

/// Use Case para crear un área del gimnasio
class CreateGymAreaUseCase {
  final GymAreasRepository repository;

  CreateGymAreaUseCase(this.repository);

  Future<Either<Failure, GymArea>> call({
    required String name,
    required String description,
    required int capacity,
    String? imageUrl,
  }) async {
    // Validaciones
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('El nombre es requerido'));
    }

    if (capacity <= 0) {
      return Left(ValidationFailure('La capacidad debe ser mayor a 0'));
    }

    return await repository.createGymArea(
      name: name,
      description: description,
      capacity: capacity,
      imageUrl: imageUrl,
    );
  }
}